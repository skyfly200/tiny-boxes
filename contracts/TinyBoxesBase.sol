//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

// needed for upgradability
//import "@openzeppelin/upgrades/contracts/Initializable.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./structs/TinyBox.sol";
import "./libraries/Utils.sol";
import "./libraries/Random.sol";

contract TinyBoxesBase is ERC721, AccessControl  {
    using Counters for Counters.Counter;
    using Random for bytes32[];

    Counters.Counter internal _tokenIds;

    // set contract config constants
    uint16 public constant TOKEN_LIMIT = 5000;
    uint8 public constant ANIMATION_COUNT = 24;
    uint8 public constant SCHEME_COUNT = 11;
    
    bool public paused = true;
    uint256 public blockStart; // start of the next phase
    uint256 public phaseLen = TOKEN_LIMIT / SCHEME_COUNT; // token count per phase
    uint256 public phaseCountdownTime = 8 minutes; // time to pause between phases
    uint256 public phaseCountdown = phaseCountdownTime.div(15); // blocks to pause between phases

    // mapping to store all the boxes info
    mapping(uint256 => TinyBox) internal boxes;

    // Create role identifiers
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    bytes32 public constant ANIMATOR_ROLE = keccak256("ANIMATOR_ROLE");

    /**
     * @dev Contract constructor.
     * @notice Constructor inherits ERC721
     */
    constructor() public ERC721("TinyBoxes", "[#][#]") {
        // TODO: setup better roles before launch
        // Grant all roles to the account deploying this contract for testing
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(ARTIST_ROLE, msg.sender);
        _setupRole(ANIMATOR_ROLE, msg.sender);
    }

    /**
     * @notice Modifier to only allow acounts of a specified role to call a function
     */
    modifier onlyRole(bytes32 _role) {
        // Check that the calling account has the required role
        require(hasRole(_role, msg.sender), "Caller dosn't have permission to use this function");
        _;
    }

    /**
     * @dev Lookup all token data in one call
     * @param _id for which we want token data
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
        mirroring = box.mirroring;
        shapes = box.shapes;
        hatching = box.hatching;
        color = [box.hue, box.saturation, box.lightness];
        size = [box.widthMin, box.widthMax, box.heightMin, box.heightMax];
        spacing = [box.spread, box.grid];
    }

    /**
     * @dev get the randomness bits for the token
     * @param id of the token to fetch randomness for
     */
    function tokenRandomness(uint256 id) external view returns (uint128) {
        TinyBox memory box = boxes[id];
        return box.randomness;
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
    }

    /**
     * @dev Calculate the randomized and phased values
     */
    function calcedParts(TinyBox memory box, uint256 id)
        internal view returns (uint8[4] memory parts)
    {
        if (id < TOKEN_LIMIT) { // Normal Tokens
            bytes32[] memory pool = Random.init(box.randomness);
            uint8[7] memory shadesBins = [1,2,5,9,5,2,1];
            uint8[24] memory animationBins = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
            // Generate Random parts from the tokens randomness
            parts[0] = uint8(pool.weighted(animationBins, 24)); // animation
            parts[1] = uint8(id.div(phaseLen)); // scheme
            parts[2] = uint8(uint256(pool.weighted(shadesBins, 25)).add(1)); //, shades
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
}
