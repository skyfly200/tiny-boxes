//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/utils/EnumerableMap.sol";

import "./TinyBoxesBase.sol";

interface RandomizerInt {
    function returnValue() external view returns (bytes32);
}

contract TinyBoxesStore is TinyBoxesBase {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using Utils for *;

    RandomizerInt entropySource;

    //uint256 public price = 100000000000000000; // in wei - 0.1 ETH
    uint256 public price = 1; // minimum for test run
    uint256 public referalPercent = 10;
    uint256 public referalNewPercent = 15;

    uint256 UINT_MAX = uint256(-1); // -1 as an unsigned integer

    address payable skyfly = 0x7A832c86002323a5de3a317b3281Eb88EC3b2C00;
    address payable natealex = 0x63a9dbCe75413036B2B778E670aaBd4493aAF9F3;

    /**
     * @dev Contract constructor.
     */
    constructor(address entropySourceAddress)
        public
        TinyBoxesBase()
    {
        entropySource = RandomizerInt(entropySourceAddress);
        // promos.set(UINT_MAX - 0, skyfly);
        // promos.set(UINT_MAX - 1, natealex);
    }

    /**
     * @dev receive direct ETH transfers
     * @notice for splitting royalties
     */
    receive() external payable {
        _splitFunds(msg.value); 
    }

    /**
     * @notice Modifier to check if tokens are sold out
     */
    modifier notSoldOut {
        require(
            _tokenIds.current() < TOKEN_LIMIT,
            "ART SALE IS OVER"
        );
        _;
    }

    /**
     * @notice Modifier to check if minting is paused
     */
    modifier notPaused {
        require(!paused, "Paused");
        _;
    }

    /**
     * @notice Modifier to check if minting is waiting for a countdown
     */
    modifier notCountdown {
        require(block.number >= blockStart, "WAIT");
        _;
    }

    /**
     * @dev set Randomizer
     */
    function setRandom(address rand) external onlyRole(ADMIN_ROLE) {
        entropySource = RandomizerInt(rand);
    }

    /**
     * @dev test Randomizer
     */
    function testRandom() external view onlyRole(ADMIN_ROLE) returns (bytes32) {
        return entropySource.returnValue();
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
     * @dev check current phase
     */
    function currentPhase() public view returns (uint8) {
        return uint8(_tokenIds.current().div(phaseLen));
    }

    /**
     * @dev calculate the true id for the limited editions
     */
    function trueID(uint256 id) public pure returns (int8) {
        return int8(int256(id));
    }

    /**
     * @dev handle the payment for tokens
     */
    function handlePayment(uint256 referalID, address recipient) internal {
        // check for suficient payment
        require(msg.value >= price, "insuficient payment");
        // give the buyer change
        if (msg.value > price) msg.sender.transfer(msg.value.sub(price));
        // lookup the referer by the referal token id owner
        address payable referer = _exists(referalID) ? payable(ownerOf(referalID)) : tx.origin;
        // give a higher percent for refering a new user
        uint256 percent = (balanceOf(tx.origin) == 0) ? referalNewPercent : referalPercent;
        // referer can't be sender or reciever - no self referals
        uint256 referal = (referer != msg.sender && referer != tx.origin && referer != recipient) ? 
            price.mul(percent).div(100) : 0; 
        // pay referal percentage
        if (referal > 0) referer.transfer(referal);
        // split remaining payment
        _splitFunds(price.sub(referal));
    }

    /**
     * @dev Split payments
     */
    function _splitFunds(uint256 amount) internal {
        if (amount > 0) {
            uint256 partA = amount.mul(60).div(100);
            skyfly.transfer(partA);
            natealex.transfer(amount.sub(partA));
        }
    }

    function validateParams(uint8 shapes, uint8 hatching, uint16[3] memory color, uint8[4] memory size, uint8[2] memory position, bool exclusive) internal pure {
        require(shapes > 0 && shapes < 31, "invalid shape count");
        require(hatching <= shapes, "invalid hatching");
        require(color[2] <= 360, "invalid color");
        require(color[1] <= 100, "invalid saturation");
        if (!exclusive) require(color[1] >= 20, "invalid saturation");
        require(color[2] <= 100, "invalid lightness");
        require(size[0] <= size[1], "invalid width range");
        require(size[2] <= size[3], "invalid height range");
        require(position[0] <= 100, "invalid spread");
    }

    /**
     * @dev Create a new TinyBox Token to a given address
     * @param _seed of token
     * @param shapes count
     * @param hatching mod value
     * @param color settings (hue, sat, light, contrast, shades)
     * @param size range for boxes
     * @param spacing grid and spread params
     * @param recipient of the token
     * @return id of the new token
     */
    function createTo(
        string calldata _seed,
        uint8 shapes,
        uint8 hatching,
        uint16[3] calldata color,
        uint8[4] calldata size,
        uint8[2] calldata spacing,
        uint8 mirroring,
        address recipient,
        uint256 referalID
    ) external payable notPaused notCountdown notSoldOut returns (uint256) {
        handlePayment(referalID, recipient);
        // check box parameters
        validateParams(shapes, hatching, color, size, spacing, false);
        // make sure caller is never the 0 address
        require(recipient != address(0), "0x00 Recipient Invalid");
        // check payment and give change
        (referalID, recipient);
        // get next id & increment the counter for the next callhandlePayment
        uint256 id = _tokenIds.current();
        _tokenIds.increment();
        // check if its time to pause for next phase countdown
        if (_tokenIds.current().mod(phaseLen) == 0)
            blockStart = block.number.add(phaseCountdown.mul(currentPhase()));
        // add block number and new token id to the seed value
        uint256 seed = _seed.stringToUint();
        // request randomness
        uint128 rand = getRandomness(id, seed);
        // create a new box object
        createBox(
            TinyBox({
                randomness: rand,
                hue: color[0],
                saturation: (rand % 200 == 0) ? uint8(0) : uint8(color[1]), // 0.5% chance of grayscale
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
            id,
            recipient
        );
        return id;
    }

    /**
     * @dev Create a Limited Edition Beta Tester TinyBox Token
     * @param seed for the token
     * @param shapes count
     * @param hatching mod value
     * @param color settings (hue, sat, light, contrast, shades)
     * @param size range for boxes
     * @param spacing grid and spread params
     * @param recipient of the token
     * @return id of the new token
     */
    function createPromo(
        uint128 seed,
        uint8 shapes,
        uint8 hatching,
        uint16[3] calldata color,
        uint8[4] calldata size,
        uint8[2] calldata spacing,
        uint8 mirroring,
        address recipient,
        uint256 id
    ) external notPaused returns (uint256) {
        // TODO - lookup promo token of matching id and burn
        // check box parameters are valid
        validateParams(shapes, hatching, color, size, spacing, true);
        // create a new box object
        createBox(
            TinyBox({
                randomness: uint128(seed),
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
            id,
            recipient
        );
        return id;
    }

    /**
     * @dev Create a new TinyBox Token
     * @param box object of token options
     * @param id of the new TinyBox token
     * @param recipient of the new TinyBox token
     */
    function createBox(TinyBox memory box, uint256 id, address recipient) private {
        boxes[id] = box; // store the new box
        _safeMint(recipient, id); // mint the new token to the recipient address
    }

    /**
     * @dev Call the Randomizer and get some randomness
     */
    function getRandomness(uint256 id, uint256 seed)
        internal view returns (uint128 randomnesss)
    {
        uint256 randomness = uint256(keccak256(abi.encodePacked(
            entropySource.returnValue(),
            id,
            seed
        ))); // mix local and Randomizer entropy for the box randomness
        return uint128(randomness % (2**128));
    }
}
