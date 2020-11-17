//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

// Chainlink Contracts
import "./chainlink/VRFConsumerBase.sol";

import "./libraries/SVGBuffer.sol";
import "./libraries/StringUtilsLib.sol";

import "./TinyBoxesPricing.sol";

import "./structs/Palette.sol";

contract TinyBoxesStore is TinyBoxesPricing, VRFConsumerBase {
    using SafeMath for uint256;
    using Utils for *;
    using SVGBuffer for bytes;
    using StringUtilsLib for *;

    // Chainlink VRF and Feed Stuff
    LinkTokenInterface LINK_TOKEN;
    // LINK Token Ropsten: 0x20fE562d797A42Dcb3399062AE9546cd06f63280
    // FEED Ropsten: 0xb8c99b98913bE2ca4899CdcaF33a3e519C20EeEc
    //address constant VRF_COORDINATOR = 0xf720CF1B963e0e7bE9F58fd471EFa67e7bF00cfb; // Ropsten
    //bytes32 constant KEY_HASH = 0xced103054e349b8dfb51352f0f8fa9b5d20dde3d06f9f43cb2b85bc64b238205; // Ropsten
    // LINK Token Kovan: 0xa36085f69e2889c224210f603d836748e7dc0088
    // FEED Kovan: 0x3Af8C569ab77af5230596Acf0E8c2F9351d24C38
    // address constant VRF_COORDINATOR = 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9; // Kovan
    // bytes32 constant KEY_HASH = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4; // Kovan
    // LINK Token Rinkeby: 0x01be23585060835e02b77ef475b0cc51aa1e0709
    // LINK/ETH FEED NOT AVAILABLE ON RINKEBY
    address constant VRF_COORDINATOR = 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B; // Rinkeby
    bytes32 constant KEY_HASH = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311; // Rinkeby
    uint256 constant fee = 10**17;
    uint256 constant DATA_PARAMETER_COUNT = 19;

    struct Request {
        address creator;
        uint256 id;
        uint256 seed;
    }

    mapping(bytes32 => Request) internal requests;

    bytes32 public constant LINK_ROLE = keccak256("LINK_ROLE");

    event LowLINK(uint256 _balance, uint256 _remaining);

    /**
     * @dev Contract constructor.
     * @notice Constructor inherits from TinyBoxesBase, TinyBoxesPricing & VRFConsumerBase
     */
    constructor(
        address _link,
        address _feed
    )
        public
        TinyBoxesBase()
        TinyBoxesPricing(_link, _feed)
        VRFConsumerBase(VRF_COORDINATOR, _link)
    {
        _setupRole(LINK_ROLE, _link);
        LINK_TOKEN = LinkTokenInterface(_link);
    }

    /**
     * @notice Modifier to check if tokens are sold out
     */
    modifier notSoldOut {
        require(
            _tokenIds.current() < TOKEN_LIMIT,
            "ART SALE IS OVER. Tinyboxes are now only available on the secondary market."
        );
        _;
    }

    /**
     * @dev handle the payment for tokens in ETH and LINK
     * @param withLink boolean flag for paying with LINK instead of ETH
     * @param amount payed
     * @param from address
     */
    function handlePayment(bool withLink, uint256 amount, address from) internal {
        // determine the current phase of the token sale
        if (_tokenIds.current() < ARTIST_PRINTS) {
            require(hasRole(ARTIST_ROLE, from), "Only the admin can mint the alpha tokens. Wait your turn FFS");
        // } else if (_tokenIds.current() < BETA_SALE) {
            // TODO: setup beta sale auction and pricing
        } else {
            uint256 price = withLink ? currentLinkPrice() : currentPrice();
            require(amount >= price, "insuficient payment");
            // give change if they over pay
            if (amount > price) {
                if (withLink) LINK_TOKEN.transfer(from, amount - price);
                else msg.sender.transfer(amount - price);
            }
        }
    }

    /**
     * @dev Withdraw LINK tokens from the contract balance to contract owner
     * @param amount of link to withdraw (in smallest divisions of 10**18)
     */
    // TODO: make a version that checks to see we have enough link to fullfill randomness for remaining unminted tokens
    function withdrawLINK(uint256 amount) external onlyRole(TREASURER_ROLE) returns (bool) {
        // ensure we have at least that much LINK
        // not needed as it is already checked for in the LINK contract
        // require(
        //     LINK_TOKEN.balanceOf(address(this)) >= amount,
        //     "Not enough LINK for requested withdraw"
        // );
        // send amount of LINK tokens to the transaction sender
        return LINK_TOKEN.transfer(msg.sender, amount);
    }

    /**
     * @dev Accept incoming LINK ERC20+677 tokens, unpack bytes data and run create with results
     * @param from address of token sender
     * @param amount of tokens transfered
     * @param data of token to create
     * @return success (token recieved) boolean value
     */
    function onTokenTransfer(
        address from,
        uint256 amount,
        bytes calldata data
    ) external onlyRole(LINK_ROLE) notSoldOut returns (bool) {
        handlePayment(true, amount, from);

        // --- Unpack parameters from raw data bytes ---

        // create data and delimiter slices
        StringUtilsLib.slice memory s = data.toString().toSlice();
        StringUtilsLib.slice memory delim = ",".toSlice();

        // check correct number of parameters are available
        require(s.count(delim) + 1 == DATA_PARAMETER_COUNT,"Invalid number of data parameters");

        // split by a comma delimiter into a string array
        string[] memory parts = new string[](s.count(delim) + 1);
        for(uint i = 0; i < parts.length; i++) {
            parts[i] = s.split(delim).toString();
        }

        uint256 seed = parts[0].stringToUint();

        // create a new box object from the unpacked parameters
        TinyBox memory box = TinyBox({
            randomness: 0,
            animation: 0,
            shapes: uint8(parts[1].stringToUint()),
            colorPalette: Palette(222,80,[30,70],6,3),//uint8(parts[2].stringToUint()),
            spacing: [
                uint16(parts[3].stringToUint()),
                uint16(parts[4].stringToUint()),
                uint16(parts[5].stringToUint()),
                uint16(parts[6].stringToUint())
            ],
            size: [
                uint16(parts[7].stringToUint()),
                uint16(parts[8].stringToUint()),
                uint16(parts[9].stringToUint()),
                uint16(parts[10].stringToUint())
            ],
            hatching: uint16(parts[11].stringToUint()),
            mirrorPositions: [int16(parts[12].stringToUint()), int16(parts[13].stringToUint()), int16(parts[14].stringToUint())],
            scale: uint16(parts[15].stringToUint())
        });

        // register the new box
        createBox(box, seed);

        // pass back to the LINK contract with a success state
        return true;
    }

    /**
     * @dev write token data to string for use when purchasing with LINK
     * @param _seed for renderer RNG
     * @param shapes count
     * @param dials for perpetual renderer
     * @param mirrors switches
     * @return preview SVG art
     */
    function dataForLINKPay(
        string memory _seed,
        uint8 shapes,
        uint16[6] memory palette,
        int16[13] memory dials,
        bool[3] memory mirrors
    ) public view returns (string memory) {
        // convert all values into a data string
        bytes memory buffer = new bytes(8192);

        buffer.append(_seed);
        buffer.append(uint256(shapes).toString());
        buffer.append(palette[0].toString());
        buffer.append(palette[1].toString());
        buffer.append(palette[2].toString());
        buffer.append(palette[3].toString());
        buffer.append(palette[4].toString());
        buffer.append(palette[5].toString());
        buffer.append(dials[0].toString());
        buffer.append(dials[1].toString());
        buffer.append(dials[2].toString());
        buffer.append(dials[3].toString());
        buffer.append(dials[4].toString());
        buffer.append(dials[5].toString());
        buffer.append(dials[6].toString());
        buffer.append(dials[7].toString());
        buffer.append(dials[8].toString());
        buffer.append(dials[9].toString());
        buffer.append(dials[10].toString());
        buffer.append(dials[11].toString());
        buffer.append(dials[12].toString());
        buffer.append(mirrors[0] ? "true": "false");
        buffer.append(mirrors[1] ? "true": "false");
        buffer.append(mirrors[2] ? "true": "false");

        return buffer.toString();
    }

    /**
     * @dev Create a new TinyBox Token
     * @param _seed of token
     * @param shapes count
     * @param palette token colors
     * @param dials of token renderer
     * @return _requestId of the VRF call
     */
    function buy(
        string calldata _seed,
        uint8 shapes,
        uint16[6] calldata palette,
        int16[13] calldata dials
    ) external payable notSoldOut returns (bytes32) {
        handlePayment(false, msg.value, msg.sender);

        // convert user seed from string to uint
        uint256 seed = _seed.stringToUint();

        // create a new box object
        TinyBox memory box = TinyBox({
            randomness: 0,
            animation: 0,
            shapes: shapes,
            colorPalette: Palette(palette[0],uint8(palette[1]),[uint8(palette[2]),uint8(palette[3])],uint8(palette[4]),uint8(palette[5])),
            spacing: [
                uint16(dials[0]),
                uint16(dials[1]),
                uint16(dials[2]),
                uint16(dials[3])
            ],
            size: [
                uint16(dials[4]),
                uint16(dials[5]),
                uint16(dials[6]),
                uint16(dials[7])
            ],
            hatching: uint16(dials[8]),
            mirrorPositions: [dials[9], dials[10], dials[11]],
            scale: uint16(dials[12])
        });

        // register the new box
        return createBox(box, seed);
    }

    /**
     * @dev Create a new TinyBox Token
     * @param box object of token data
     * @return _requestId of the VRF call
     */
    function createBox(TinyBox memory box, uint256 _seed) internal returns (bytes32) {
        // make sure caller is never the 0 address
        require(
            msg.sender != address(0),
            "token recipient man not be the zero address"
        );
        // ensure we have enough LINK token in the contract to pay for VRF request fee
        uint256 balance = LINK_TOKEN.balanceOf(address(this));
        uint256 remaining = TOKEN_LIMIT - (_tokenIds.current() + 1);
        require(
            balance >= fee,
            "Not enough LINK for a VRF request"
        );
        // fire LINK_LOW event if LINK is to low to fullfill remaining VRF requests needed to sell out tokens
        if (balance < (remaining * fee)) emit LowLINK(balance, remaining);

        // store the current id & increment the counter for the next call
        uint256 id = _tokenIds.current();
        _tokenIds.increment();

        // register the new box data
        boxes[id] = box;

        // add block number and new token id into the seed value
        uint256 seed = _seed.add(block.number).add(id).mod(uint256(2**64));

        // send VRF request
        bytes32 _requestId = requestRandomness(KEY_HASH, fee, seed);

        // map VRF requestId to next token id and owner
        requests[_requestId] = Request(msg.sender, id, seed);

        return _requestId;
    }

    /**
     * @notice Callback function used by VRF Coordinator
     * @dev Important! Add a modifier to only allow this function to be called by the VRFCoordinator
     * @dev This is where you do something with randomness!
     * @dev The VRF Coordinator will only send this function verified responses.
     * @dev The VRF Coordinator will not pass randomness that could not be verified.
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        external
        override
    {
        // lookup VRF Request by id
        Request memory req = requests[requestId];

        // TODO - generate animation with RNG weighted non uniformly for varying rarity types
        //        maybe use log base 2 of a number in a range 2 to the animation counts

        // generate params with RNG & save to the box along with the randomness
        boxes[req.id].randomness = randomness;
        boxes[req.id].animation = uint8(randomness.mod(ANIMATION_COUNT));

        _safeMint(req.creator, req.id);
    }
}
