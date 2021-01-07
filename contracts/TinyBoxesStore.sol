//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SignedSafeMath.sol";

import "./TinyBoxesPricing.sol";

import "./libraries/Random.sol";

interface Randomizer {
    function returnValue() external returns (bytes32);
}

contract TinyBoxesStore is TinyBoxesPricing {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using Utils for *;
    using Random for bytes32[];

    bool public paused = false;
    uint256 public blockStart; // start of the next phase
    uint256 public phaseLen = TOKEN_LIMIT / 10; // token count per phase
    uint256 public phaseCountdownTime = 20 hours; // time to pause between phases
    uint256 public phaseCountdown = phaseCountdownTime.div(15); // blocks to pause between phases

    Randomizer entropySource;

    /**
     * @dev Contract constructor.
     * @notice Constructor inherits from TinyBoxesPricing
     */
    constructor(address entropySourceAddress)
        public
        TinyBoxesBase()
    {
        blockStart = block.number;
        entropySource = Randomizer(entropySourceAddress);
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
     * @dev Create a new TinyBox Token
     * @param _seed of token
     * @param shapes count
     * @param hatching mod value
     * @param color settings (hue, sat, light, contrast, shades)
     * @param size range for boxes
     * @param spacing grid and spread params
     * @return id of the new token
     */
    function buy(
        string calldata _seed,
        uint8 shapes,
        uint8 hatching,
        uint16[4] calldata color,
        uint8[4] calldata size,
        uint8[2] calldata spacing
    ) external payable notPaused notSoldOut returns (uint256) {
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
     * @return id of the new token
     */
    function buyFor(
        string memory _seed,
        uint8 shapes,
        uint8 hatching,
        uint16[4] memory color,
        uint8[4] memory size,
        uint8[2] memory spacing,
        address recipient
    ) public payable notPaused notSoldOut returns (uint256) {
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
                mirroring: 0,
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
     * @param _seed for the RNG
     * @param recipient of the new TinyBox token
     * @return id of the new token
     */
    function createBox(TinyBox memory box, uint256 _seed, address recipient) private returns (uint256) {
        // make sure caller is never the 0 address
        require(
            recipient != address(0),
            "0x00 Recipient Invalid"
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

        // randomize the box
        randomizeBox(id, seed);

        // mint the new token to the recipient address
        _safeMint(recipient, id);

        return id;
    }

    /**
     * @dev Call the Randomizer and update random values
     */
    function randomizeBox(uint256 id, uint256 seed)
        internal
    {
        uint256 randomness = uint256(keccak256(abi.encodePacked(
            entropySource.returnValue(),
            id,
            seed
        ))); // mix local and Randomizer entropy for the box randomness

        boxRand[id] = uint32(randomness % (2**32));

        bytes32[] memory pool = Random.init(randomness);

        // TODO - generate animation with RNG weighted non uniformly for varying rarity types
        // update RNG set values
        boxes[id].animation = uint8(pool.uniform(0, (ANIMATION_COUNT - 1))); // animation
        boxes[id].scheme = uint8(id.div(phaseLen)); // scheme
        boxes[id].shades = uint8(pool.uniform(1, 8)); // shades
        boxes[id].mirroring = uint8(pool.uniform(0, 7)); // mirroring mode

        // set the last 5 per phase to grayscale
        if (id.mod(phaseLen) >= (phaseLen.sub(5))) boxes[id].color.saturation = 0;
    }
}
