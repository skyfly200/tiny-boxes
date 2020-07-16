//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

// Chainlink Contracts
import "./chainlink/VRFConsumerBase.sol";

import "./TinyBoxesPricing.sol";

import "./libraries/Random.sol";
import "./libraries/SVGBuffer.sol";
import "./libraries/StringUtilsLib.sol";

contract TinyBoxesStore is TinyBoxesPricing, VRFConsumerBase {
    using SafeMath for uint256;
    using Utils for string;
    using SVGBuffer for bytes;
    using StringUtilsLib for *;

    // Chainlink VRF and Feed Stuff
    // LINK ropsten address: 0x20fE562d797A42Dcb3399062AE9546cd06f63280
    LinkTokenInterface LINK_TOKEN;
    // feed ropsten address: 0xb8c99b98913bE2ca4899CdcaF33a3e519C20EeEc
    address constant VRF_COORDINATOR = 0xf720CF1B963e0e7bE9F58fd471EFa67e7bF00cfb; // Ropsten
    bytes32 constant KEY_HASH = 0xced103054e349b8dfb51352f0f8fa9b5d20dde3d06f9f43cb2b85bc64b238205; // Ropsten
    // address constant VRF_COORDINATOR = 0xc1031337fe8E75Cf25CAe9828F3BF734d83732e4; // Rinkeby
    //bytes32 constant KEY_HASH = 0xcad496b9d0416369213648a32b4975fff8707f05dfb43603961b58f3ac6617a7; // Rinkeby
    uint256 constant fee = 10**17;
    uint256 constant DATA_PARAMETER_COUNT = 19;

    struct Request {
        address creator;
        uint256 id;
        uint256 seed;
    }

    mapping(bytes32 => Request) internal requests;

    bytes32 public constant LINK_ROLE = keccak256("LINK_ROLE");

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
     * @dev handle the payment for tokens
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
            seed: seed,
            randomness: 0,
            animation: 0,
            shapes: uint8(parts[1].stringToUint()),
            colors: uint8(parts[2].stringToUint()),
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
            scale: uint16(parts[15].stringToUint()),
            mirrors: [parts[16].stringToUint() != 0, parts[17].stringToUint() != 0, parts[18].stringToUint() != 0]
        });

        // register the new box
        createBox(box, seed);

        // pass back to the LINK contract with a success state
        return true;
    }

    /**
     * @dev Create a new TinyBox Token
     * @param _seed of token
     * @param counts of token colors & shapes
     * @param dials of token renderer
     * @param mirrors active boolean of token
     * @return _requestId of the VRF call
     */
    function buy(
        string calldata _seed,
        uint8[2] calldata counts,
        int16[13] calldata dials,
        bool[3] calldata mirrors
    ) external payable notSoldOut returns (bytes32) {
        // TODO: uncomment again for production
        //handlePayment(false, msg.value, msg.sender);

        // convert user seed from string to uint
        uint256 seed = _seed.stringToUint();

        // create a new box object
        TinyBox memory box = TinyBox({
            seed: seed,
            randomness: 0,
            animation: 0,
            shapes: counts[1],
            colors: counts[0],
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
            scale: uint16(dials[12]),
            mirrors: mirrors
        });

        // register the new box
        return createBox(box, seed);
    }

    /**
     * @dev Create a new TinyBox Token
     * @param box object of token data
     * @return _requestId of the VRF call
     */
    function createBox(TinyBox memory box, uint256 seed) internal returns (bytes32) {
        // make sure caller is never the 0 address
        require(
            msg.sender != address(0),
            "token recipient man not be the zero address"
        );
        // ensure we have enough LINK token in the contract to pay for VRF request fee
        require(
            LINK_TOKEN.balanceOf(address(this)) >= fee,
            "Not enough LINK for a VRF request"
        );
        // TODO: fire LINK_LOW event here if LINK is to low to fullfill remaining VRF requests needed to sell out

        // store the current id & increment the counter for the next call
        uint256 id = _tokenIds.current();
        _tokenIds.increment();

        // register the new box data
        boxes[id] = box;

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
        internal
        override
    {
        // lookup VRF Request by id
        Request memory req = requests[requestId];

        // TODO - generate animation with RNG weighted non uniformly for varying rarity types
        //        maybe use log base 2 of a number in a range 2 to the animation counts

        // generate params with RNG & save to the box along with the randomness
        // boxes[req.id].randomness = randomness;
        // boxes[req.id].animation = uint8(randomness.mod(ANIMATION_COUNT));

        _safeMint(req.creator, req.id);
    }
}
