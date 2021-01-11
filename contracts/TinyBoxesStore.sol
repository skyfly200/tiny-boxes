//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SignedSafeMath.sol";

import "./TinyBoxesBase.sol";

interface Randomizer {
    function returnValue() external returns (bytes32);
}

contract TinyBoxesStore is TinyBoxesBase {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using Utils for *;

    Randomizer entropySource;

    uint256 public price = 35000000000000000; // in wei

    /**
     * @dev Contract constructor.
     */
    constructor(address entropySourceAddress)
        public
        TinyBoxesBase()
    {
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
     * @dev set Randomizer
     */
    function setRandom(address rand) external onlyRole(ADMIN_ROLE) {
        entropySource = Randomizer(rand);
    }

    /**
     * @dev pause minting
     */
    function setPause(bool state) external onlyRole(ADMIN_ROLE) {
        paused = state;
    }

    /**
     * @dev set start block for next phase
     */
    function startCoundown(uint256 startBlock) external onlyRole(ADMIN_ROLE) {
        require(startBlock > block.number,"Must be future block");
        blockStart = startBlock;
        paused = false;
    }

    /**
     * @dev handle the payment for tokens
     */
    function handlePayment() internal {
        // check for suficient payment
        uint256 amount = msg.value;
        require(amount >= price, "insuficient payment");
        // give change if they over pay
        if (amount > price) msg.sender.transfer(amount - price);
    }

    function validateParams(uint8 shapes, uint8 hatching, uint16[3] memory color, uint8[4] memory size, uint8[2] memory position) internal pure {
        require(shapes > 0 && shapes < 31, "invalid shape count");
        require(hatching <= shapes, "invalid hatching");
        require(color[1] >= 20 && color[1] <= 100, "invalid saturation");
        require(color[2] <= 100, "invalid lightness");
        require(size[0] <= size[1], "invalid width range");
        require(size[2] <= size[3], "invalid height range");
        require(position[0] <= 100, "invalid spread");
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
        string calldata _seed,
        uint8 shapes,
        uint8 hatching,
        uint16[3] calldata color,
        uint8[4] calldata size,
        uint8[2] calldata spacing,
        uint8 mirroring,
        address recipient
    ) external payable notPaused notSoldOut returns (uint256) {
        // check box parameters
        validateParams(shapes, hatching, color, size, spacing);
        // make sure caller is never the 0 address
        require(
            recipient != address(0),
            "0x00 Recipient Invalid"
        );
        // check payment and give change
        handlePayment();
        // create a new box object
        return createBox(
            TinyBox({
                randomness: 0,
                hue: color[0],
                saturation: uint8(color[1]),
                lightness: uint8(color[2]),
                shapes: shapes,
                hatching: hatching,
                widthMin: size[0],
                widthMax: size[1],
                heightMin: size[2],
                heightMax: size[3],
                spread: spacing[0],
                grid: spacing[1],
                mirroring: mirroring,
                bkg: 0,
                duration: 10,
                options: 1
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
        // get the current id & increment the counter for the next call
        uint256 id = _tokenIds.current();
        _tokenIds.increment();

        // check if its time to pause for next phase countdown
        if (_tokenIds.current() % phaseLen == 0) blockStart = block.number.add(phaseCountdown);

        // add block number and new token id to the seed value
        uint256 seed = _seed.add(block.number).add(id).mod(uint256(2**64));

        // get some entropy
        box.randomness = getRandomness(id, seed);

        // set the last 5 per phase to grayscale
        if (id.mod(phaseLen) >= (phaseLen.sub(5))) box.saturation = 0;

        // store the new box
        boxes[id] = box;

        // mint the new token to the recipient address
        _safeMint(recipient, id);

        return id;
    }

    /**
     * @dev Call the Randomizer and get some randomness
     */
    function getRandomness(uint256 id, uint256 seed)
        internal returns (uint128 randomnesss)
    {
        uint256 randomness = uint256(keccak256(abi.encodePacked(
            entropySource.returnValue(),
            id,
            seed
        ))); // mix local and Randomizer entropy for the box randomness
        return uint128(randomness % (2**128));
    }
}
