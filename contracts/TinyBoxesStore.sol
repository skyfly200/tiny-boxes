//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

// Chainlink Contracts
import "./chainlink/VRFConsumerBase.sol";

import "./TinyBoxesBase.sol";
import "./TinyBoxesPricing.sol";

import "./libraries/Random.sol";

contract TinyBoxesStore is TinyBoxesBase, TinyBoxesPricing, VRFConsumerBase {
    using SafeMath for uint256;
    using Utils for string;

    // Chainlink VRF and Feed Stuff
    // LINK Ropstein Address: 0x20fE562d797A42Dcb3399062AE9546cd06f63280
    address constant VRF_COORDINATOR = 0xf720CF1B963e0e7bE9F58fd471EFa67e7bF00cfb; // Ropsten
    bytes32 constant KEY_HASH = 0xced103054e349b8dfb51352f0f8fa9b5d20dde3d06f9f43cb2b85bc64b238205; // Ropsten
    // address constant VRF_COORDINATOR = 0xc1031337fe8E75Cf25CAe9828F3BF734d83732e4; // Rinkeby
    //bytes32 constant KEY_HASH = 0xcad496b9d0416369213648a32b4975fff8707f05dfb43603961b58f3ac6617a7; // Rinkeby
    uint256 constant fee = 10**18;

    struct Request {
        address creator;
        uint256 id;
    }

    mapping(bytes32 => Request) internal requests;

    // Create role identifiers
    bytes32 public constant LINK_ROLE = keccak256("LINK_ROLE");
    bytes32 public constant VRF_ROLE = keccak256("VRF_ROLE");

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
        VRFConsumerBase(VRF_COORDINATOR, chainlinkTokenAddress())
    {
        // Grant roles to the LINK and VRF_COORDINATOR contract addresses
        _setupRole(LINK_ROLE, chainlinkTokenAddress());
        _setupRole(VRF_ROLE, VRF_COORDINATOR);
    }

    /**
     * @notice Modifier to check if tokens are sold out
     */
    modifier notSoldOut {
        // ensure we still have not reached the cap
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
        // check if still minting the artist tokens
        if (_tokenIds.current() < ARTIST_PRINTS) {
            // Check that the calling account has the artist role
            require(hasRole(ARTIST_ROLE, from), "Only the admin can mint the alpha tokens. Wait your turn FFS");
        } else {
            // TODO: setup beta sale auction and pricing
            // if still minting the beta sale
            // else minting public release
            uint256 price = withLink ? currentLinkPrice() : currentPrice();
            require(amount >= price, "insuficient payment"); // return if they dont pay enough
            // give change if they over pay
            if (amount > price) { 
                if (withLink) LINK_TOKEN.transfer(from, amount - price); // change in LINK
                else msg.sender.transfer(amount - price); // change in ETH
            }
        }
    }

    /**
     * @dev Get the current price of a token
     * @return price in wei of a token currently
     */
    function currentPrice() public view returns (uint256 price) {
        price = priceAt(_tokenIds.current());
    }

    /**
     * @dev Get the current price of a token in LINK (Chainlink Token)
     * @return price in LINK of a token currently
     */
    function currentLinkPrice() public view returns (uint256 price) {
        price = linkPriceAt(_tokenIds.current());
    }

    /**
     * @dev Approve an address for LINK withdraws
     * @param account address to approve
     */
    function aproveLINKWithdraws(address account) external onlyRole(ADMIN_ROLE) {
        // set account address to true in witdraw aproval mapping
        _setupRole(TREASURER_ROLE, account);
    }

    /**
     * @dev Withdraw LINK tokens from the contract balance to contract owner
     * @param amount of link to withdraw (in smallest divisions of 10**18)
     */
    // TODO: make a version that checks to see we have enough link to fullfill randomness for remaining unminted tokens
    function withdrawLINK(uint256 amount) external onlyRole(TREASURER_ROLE) returns (bool) {
        // ensure we have at least that much LINK
        require(
            LINK_TOKEN.balanceOf(address(this)) >= amount,
            "Not enough LINK for requested withdraw"
        );
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
        // check payment amount is greaterthan or equal to current token price
        // give change if over payed
        handlePayment(true, amount, from);

        // TODO: unpack parameters from bytes data
        // create variables to unpack data into
        uint256 seed = 0;
        uint8[2] memory counts = [1, 1];
        int16[13] memory dials = [
            int16(100),
            int16(100),
            int16(3),
            int16(3),
            int16(100),
            int16(200),
            int16(100),
            int16(200),
            int16(3),
            int16(750),
            int16(1200),
            int16(2400),
            int16(100)
        ];
        bool[3] memory mirrors = [true, true, true];

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
        createBox(box);

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
        handlePayment(false, msg.value, msg.sender);

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
        return createBox(box);
    }

    /**
     * @dev Create a new TinyBox Token
     * @param box object of token data
     * @return _requestId of the VRF call
     */
    function createBox(TinyBox memory box) internal returns (bytes32) {
        // make sure caller is never the 0 address
        require(
            msg.sender != address(0),
            "token recipient man not be the zero address"
        );
        // ensure we have enough LINK token in the contract to pay for VRF
        require(
            LINK_TOKEN.balanceOf(address(this)) > fee,
            "Not enough LINK for a VRF request"
        );

        // register the new box data
        boxes[_tokenIds.current()] = box;

        // Hash user seed and blockhash for VRFSeed
        uint256 seedVRF = uint256(
            keccak256(abi.encode(box.seed, blockhash(block.number)))
        );

        // send VRF request
        bytes32 _requestId = requestRandomness(KEY_HASH, fee, seedVRF);

        // map VRF requestId to next token id and owner
        requests[_requestId] = Request(msg.sender, _tokenIds.current());

        // increment the id counter for the next call
        _tokenIds.increment();

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
        onlyRole(VRF_ROLE)
    {
        // lookup saved data from the requestId
        Request memory req = requests[requestId];

        // store the randomness in the token data
        boxes[req.id].randomness = randomness;

        // --- Use The Provided Randomness ---

        // initilized RNG with the provided varifiable randomness and blocks 0 through 1
        bytes32[] memory pool = Random.init(0, 1, randomness);

        // TODO - generate animation with RNG weighted non uniformly for varying rarity types
        // maybe use log base 2 of a number in a range 2 to the animation counts
        uint8 animation = uint8(
            Random.uniform(pool, 0, int256(ANIMATION_COUNT) - 1)
        );

        // --- Save data to storage ---

        // update box data relying on randomness
        boxes[req.id].animation = animation;

        // mint the token to the creator
        _safeMint(req.creator, req.id);
    }
}
