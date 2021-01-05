//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

// Chainlink Contracts
import "./chainlink/VRFConsumerBase.sol";

import "@openzeppelin/contracts/math/SignedSafeMath.sol";

import "./TinyBoxesPricing.sol";

import "./libraries/Random.sol";

contract TinyBoxesStore is TinyBoxesPricing, VRFConsumerBase {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using Utils for *;
    using Random for bytes32[];

    // Chainlink VRF stuff
    LinkTokenInterface LINK_TOKEN;
    // LINK Token Ropsten: 0x20fE562d797A42Dcb3399062AE9546cd06f63280
    //address constant VRF_COORDINATOR = 0xf720CF1B963e0e7bE9F58fd471EFa67e7bF00cfb; // Ropsten
    //bytes32 constant KEY_HASH = 0xced103054e349b8dfb51352f0f8fa9b5d20dde3d06f9f43cb2b85bc64b238205; // Ropsten
    // LINK Token Kovan: 0xa36085f69e2889c224210f603d836748e7dc0088
    // address constant VRF_COORDINATOR = 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9; // Kovan
    // bytes32 constant KEY_HASH = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4; // Kovan
    // LINK Token Rinkeby: 0x01be23585060835e02b77ef475b0cc51aa1e0709
    address constant VRF_COORDINATOR = 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B; // Rinkeby
    bytes32 constant KEY_HASH = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311; // Rinkeby
    uint256 constant fee = 10**17;

    bool public paused = false;
    uint256 public blockStart; // start of the next phase
    uint256 public phaseLen = TOKEN_LIMIT / ANIMATION_COUNT; // token count per phase
    uint256 public phaseCountdownTime = 20 hours; // time to pause between phases
    uint256 public phaseCountdown = phaseCountdownTime.div(15); // blocks to pause between phases

    struct Request {
        address recipient;
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
        address _link
    )
        public
        TinyBoxesBase()
        VRFConsumerBase(VRF_COORDINATOR, _link)
    {
        _setupRole(LINK_ROLE, _link);
        LINK_TOKEN = LinkTokenInterface(_link);
        blockStart = block.number;
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
     * @notice Modifier to check if minting is paused
     */
    modifier notPaused {
        require(!paused, "paused");
        require(block.number >= blockStart, "phase paused");
        _;
    }

    /**
     * @dev pause minting
     */
    function setPause(bool state) external onlyRole(ADMIN_ROLE) {
        paused = state;
    }

    /**
     * @dev handle the payment for tokens
     */
    function handlePayment() internal {
        // check for suficient payment
        uint256 amount = msg.value;
        uint256 price = currentPrice();
        require(amount >= price, "insuficient payment");
        // give change if they over pay
        if (amount > price) msg.sender.transfer(amount - price);
    }

    function validateParams(uint16[4] memory color) internal pure {
        require(color[0] <= 360, "invalid hue");
        require(color[1] >= 10 && color[1] <= 100, "invalid saturation");
        require(color[2] <= 100, "invalid lightness");
        require(int256(color[2]).sub(color[3]) >= 0, "invalid contrast");
    }

    /**
     * @dev Withdraw LINK tokens from the contract balance to contract owner
     * @param amount of link to withdraw (in smallest divisions of 10**18)
     */
    // TODO: make a version that checks to see we have enough link to fullfill randomness for remaining unminted tokens
    function withdrawLINK(uint256 amount) external onlyRole(ADMIN_ROLE) returns (bool) {
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
     * @dev Create a new TinyBox Token
     * @param _seed of token
     * @param shapes count
     * @param hatching mod value
     * @param color settings (hue, sat, light, contrast, shades)
     * @param size range for boxes
     * @param spacing grid and spread params
     * @return _requestId of the VRF call
     */
    function buy(
        string calldata _seed,
        uint8 shapes,
        uint8 hatching,
        uint16[4] calldata color,
        uint8[4] calldata size,
        uint8[2] calldata spacing
    ) external payable notPaused notSoldOut returns (bytes32) {
        return buyFor(_seed, shapes, hatching, color, size, spacing, msg.sender);
    }

    /**
     * @dev Create a new TinyBox Token
     * @param _seed of token
     * @param shapes count
     * @param hatching mod value
     * @param color settings (hue, sat, light, contrast, shades)
     * @param size range for boxes
     * @param spacing grid and spread params
     * @param recipient of the token
     * @return _requestId of the VRF call
     */
    function buyFor(
        string memory _seed,
        uint8 shapes,
        uint8 hatching,
        uint16[4] memory color,
        uint8[4] memory size,
        uint8[2] memory spacing,
        address recipient
    ) public payable notPaused notSoldOut returns (bytes32) {
        // check box parameters
        validateParams(color);

        // check payment and give change
        handlePayment();

        // create a new box object
        return createBox(
            TinyBox({
                color: HSL(color[0],uint8(color[1]),uint8(color[2])),
                contrast: uint8(color[3]),
                shapes: shapes,
                hatching: hatching,
                size: size,
                spacing: spacing,
                mirroring: [0,0],
                scheme: 0,
                shades: 0,
                animation: 0
            }),
            _seed.stringToUint(),
            recipient
        );
    }

    /**
     * @dev Create a new TinyBox Token
     * @param box object of token options
     * @param _seed for the VRF request
     * @param recipient of the new TinyBox token
     * @return _requestId of the VRF call
     */
    function createBox(TinyBox memory box, uint256 _seed, address recipient) private returns (bytes32) {
        // make sure caller is never the 0 address
        require(
            recipient != address(0),
            "0x00 Recipient Invalid"
        );
        // ensure we have enough LINK token in the contract to pay for VRF request fee
        uint256 balance = LINK_TOKEN.balanceOf(address(this));
        require(
            balance >= fee,
            "LINK 2 Low 4 VRF"
        );

        // store the current id & increment the counter for the next call
        uint256 id = _tokenIds.current();
        _tokenIds.increment();

        // register the new box data
        boxes[id] = box;

        // check if its time tpopause for next phase countdown
        if (_tokenIds.current() % phaseLen == 0) blockStart = block.number.add(phaseCountdown);

        // add block number and new token id to the seed value
        uint256 seed = _seed.add(block.number).add(id).mod(uint256(2**64));

        // send VRF request
        bytes32 _requestId = requestRandomness(KEY_HASH, fee, seed);

        // map VRF requestId to next token id and owner
        requests[_requestId] = Request(recipient, id, seed);

        return _requestId;
    }

    /**
     * @notice Callback function used by VRF Coordinator
     * @dev The VRF Coordinator will only send this function verified responses.
     * @dev The VRF Coordinator will not pass randomness that could not be verified.
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        // lookup VRF Request
        Request memory req = requests[requestId];

        boxRand[req.id] = randomness;

        bytes32[] memory pool = Random.init(randomness);

        // TODO - generate animation with RNG weighted non uniformly for varying rarity types
        // update RNG set values
        boxes[req.id].animation = uint8(req.id.div(phaseLen)); // animation
        boxes[req.id].scheme = uint8(pool.uniform(0, 9)); // scheme
        boxes[req.id].shades = uint8(pool.uniform(1, 8)); // shades
        boxes[req.id].mirroring = [
            uint8(pool.uniform(0, 7)), // mirroring switches
            uint8(pool.uniform(0, 7)) // mirroring types
        ];

        // mint the new token to the recipient address
        _safeMint(req.recipient, req.id);

        // fire LINK_LOW event if LINK is too low to fullfill remaining VRF requests needed to sell out tokens
        uint256 balance = LINK_TOKEN.balanceOf(address(this));
        uint256 remaining = TOKEN_LIMIT - (_tokenIds.current() + 1);
        if (balance < (remaining * fee)) emit LowLINK(balance, remaining);
    }
}
