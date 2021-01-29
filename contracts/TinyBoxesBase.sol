// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./structs/TinyBox.sol";
import "./libraries/Utils.sol";
import "./libraries/Random.sol";

interface RandomizerInt {
    function returnValue() external view returns (bytes32);
}

contract TinyBoxesBase is ERC721, AccessControl  {
    using Counters for Counters.Counter;
    using Random for bytes32[];

    Counters.Counter public _tokenIds;
    Counters.Counter public _tokenPromoIds;

    RandomizerInt entropySource;

    // set contract config constants

    address payable skyfly = 0x7A832c86002323a5de3a317b3281Eb88EC3b2C00;
    address payable natealex = 0x63a9dbCe75413036B2B778E670aaBd4493aAF9F3;

    uint256 public constant price = 100000000000000000; // in wei - 0.1 ETH
    uint256 public constant referalPercent = 10;
    uint256 public constant referalNewPercent = 15;
    uint256 UINT_MAX = uint256(-1);
    uint256 MAX_PROMOS = 100;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE"); // define the admin role identifier
    uint16 public constant TOKEN_LIMIT = 2222;
    uint8 public constant ANIMATION_COUNT = 24;
    uint8 public constant SCHEME_COUNT = 11;
    uint8 public constant avgBlockTime = 14; // avg time per block mined in seconds
    uint16 public constant phaseLen = TOKEN_LIMIT / SCHEME_COUNT; // token count per phase
    uint32 public constant phaseCountdownTime = 6 hours; // time to pause between phases
    
    // set dynamic contract config
    bool public paused = true;
    uint256 public blockStart; // next block that minting will start on, countdown end point
    uint256 public phaseCountdown = uint256(phaseCountdownTime / avgBlockTime); // blocks to pause between phases
    string public contractURI = "https://tinybox.shop/TinyBoxes.json";

    // mapping to store all the boxes info
    mapping(uint256 => TinyBox) internal boxes;

    event SettingsChanged(uint8[3] settings);

    /**
     * @dev Contract constructor.
     * @notice Constructor inherits ERC721
     */
    constructor(address entropySourceAddress) public ERC721("TinyBoxes", "[#][#]") {
        _setupRole(ADMIN_ROLE, msg.sender);
        entropySource = RandomizerInt(entropySourceAddress);
    }

    // Require Functions

    /**
     * @notice  only allow acounts of a specified role to call a function
     */
    function onlyRole(bytes32 _role) view internal {
        // Check that the calling account has the required role
        require(hasRole(_role, msg.sender), "DENIED");
    }

    /**
     * @notice check if tokens are sold out
     */
    function notSoldOut() view internal {
        require(_tokenIds.current() < TOKEN_LIMIT, "SOLD OUT");
    }

    /**
     * @notice check if minting is paused
     */
    function notPaused() view internal {
        require(!paused, "Paused");
    }

    /**
     * @notice check if minting is waiting for a countdown
     */
    function notCountdown() view internal {
        require(block.number >= blockStart, "WAIT");
    }

    // Store Mgmt. Functions

    /**
     * @dev pause minting
     */
    function setPause(bool state) external {
        onlyRole(ADMIN_ROLE);
        paused = state;
    }

    /**
     * @dev set start block for next phase
     */
    function startCountdown(uint256 startBlock) external {
        onlyRole(ADMIN_ROLE);
        require(startBlock > block.number,"Must be future block");
        blockStart = startBlock;
        paused = false;
    }

    // Randomizer functions

    /**
     * @dev set Randomizer
     */
    function setRandom(address rand) external {
        onlyRole(ADMIN_ROLE);
        entropySource = RandomizerInt(rand);
    }

    /**
     * @dev test Randomizer
     */
    function testRandom() external view returns (bytes32) {
        onlyRole(ADMIN_ROLE);
        return entropySource.returnValue();
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
        return uint128(randomness % (2**128)); // cut off half the bits
    }

    // Metadata URI Functions

    /**
     * @dev Set the tokens URI
     * @param _id of a token to update
     * @param _uri for the token
     * @dev Only the admin can call this
     */
    function setTokenURI(uint256 _id, string calldata _uri) external {
        onlyRole(ADMIN_ROLE);
        _setTokenURI(_id, _uri);
    }

    /**
     * @dev Update the base URI field
     * @param _uri base for all tokens 
     * @dev Only the admin can call this
     */
    function setBaseURI(string calldata _uri) external {
        onlyRole(ADMIN_ROLE);
        _setBaseURI(_uri);
    }

    /**
     * @dev Update the contract URI field
     * @dev Only the admin can call this
     */
    function setContractURI(string calldata _uri) external {
        onlyRole(ADMIN_ROLE);
        contractURI = _uri;
    }

    // Utility Functions

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
     * @dev check if id is one of limited editions
     * @param id of token to check
     */
    function isTokenLE(uint256 id) public view returns (bool) {
        return id > UINT_MAX - MAX_PROMOS;
    }

    // Token Info - Data & Settings

    /**
     * @dev Lookup all token data in one call
     * @param _id for which we want token data
     * @return randomness of the token
     * @return animation of token
     * @return shapes of token
     * @return hatching of token
     * @return size of token
     * @return spacing of token
     * @return mirroring of token
     * @return color for palette root
     * @return contrast of the palette
     * @return shades for palette
     * @return scheme for palette
     */
    function tokenData(uint256 _id)
        external
        view
        returns (
            uint128 randomness,
            uint256 animation,
            uint8 shapes,
            uint8 hatching,
            uint8[4] memory size,
            uint8[2] memory spacing,
            uint8 mirroring,
            uint16[3] memory color,
            uint8 contrast,
            uint8 shades,
            uint8 scheme
        )
    {
        TinyBox memory box = boxes[_id];
        uint8[4] memory parts = calcedParts(box, _id);

        animation = parts[0];
        scheme = parts[1];
        shades = parts[2];
        contrast = parts[3];

        randomness = box.randomness;
        mirroring = box.mirroring;
        shapes = box.shapes;
        hatching = box.hatching;
        color = [box.hue, box.saturation, box.lightness];
        size = [box.widthMin, box.widthMax, box.heightMin, box.heightMax];
        spacing = [box.spread, box.grid];
    }

    /**
     * @dev read the dynamic rendering settings of a token
     * @param id of the token to fetch settings for
     */
    function readSettings(uint256 id) external view returns (uint8 bkg, uint8 duration, uint8 options) {
        TinyBox memory box = boxes[id];
        bkg = box.bkg;
        duration = box.duration;
        options = box.options;
    }

    /**
     * @dev set the dynamic rendering options of a token
     * @param id of the token to update
     * @param settings new settings values
     */
    function changeSettings(uint256 id, uint8[3] calldata settings) external {
        require(msg.sender == ownerOf(id) || msg.sender == getApproved(id), "Insuf. Permissions");
        require(settings[0] <= 101, "Invalid Bkg");
        require(settings[1] > 0, "Invalid Duration");
        boxes[id].bkg = settings[0];
        boxes[id].duration = settings[1];
        boxes[id].options = settings[2];
        emit SettingsChanged(settings);
    }

    /**
     * @dev Calculate the randomized and phased values
     */
    function calcedParts(TinyBox memory box, uint256 id) internal view returns (uint8[4] memory parts)
    {
        if (id < TOKEN_LIMIT) { // Normal Tokens
            bytes32[] memory pool = Random.init(box.randomness);
            uint8[7] memory shadesBins = [4,6,9,6,4,2,1];
            uint8[24] memory animationBins = [
                175, // Snap Spin 90
                200, // Snap Spin 180
                175, // Snap Spin 270
                160, // Snap Spin Tri
                150, // Snap Spin Quad
                140, // Snap Spin Tetra
                95, // Spin
                100, // Slow Mo
                90, // Clockwork
                20, // Spread
                10, // Staggered Spread
                80, // Jitter
                75, // Giggle
                85, // Jolt
                110, // Grow n Shrink
                105, // Squash n Stretch
                50, // Round
                90, // Glide
                70, // Wave
                40, // Fade
                140, // Skew X
                130, // Skew Y
                100, // Stretch
                110 // Jello
            ];
            // Generate Random parts from the tokens randomness
            parts[0] = uint8(pool.weighted(animationBins, 2500)); // animation
            parts[1] = uint8(id.div(phaseLen)); // scheme
            parts[2] = uint8(uint256(pool.weighted(shadesBins, 32)).add(1)); //, shades
            parts[3] = uint8(pool.uniform(0, box.lightness)); // contrast
        } else { // Limited Editions
            // Set the parts directly from packed values in the randomness
            // Anim(5), Scheme(4), Shades(3), Contrast(7) & Vanity Rand String(17xASCII(7))
            parts[0] = uint8(box.randomness / 2**123); // animation
            parts[1] = uint8((box.randomness / 2**119) % 2**4); // scheme
            parts[2] = uint8((box.randomness / 2**116) % 2**3); //, shades
            parts[3] = uint8((box.randomness / 2**109) % 2**7); // contrast
        }
    }

    /**
     * @dev Validate the parameters for the docs
     */
    function validateParams(uint8 shapes, uint8 hatching, uint16[3] memory color, uint8[4] memory size, uint8[2] memory position, bool exclusive) public pure {
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
}
