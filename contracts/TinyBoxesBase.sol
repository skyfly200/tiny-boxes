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

contract TinyBoxesBase is ERC721, AccessControl  {
    using Counters for Counters.Counter;

    Counters.Counter internal _tokenIds;

    // set contract config constants
    uint256 public constant TOKEN_LIMIT = 1000;
    uint256 public constant ARTIST_PRINTS = 0; // TODO: set to 2 before launch
    uint256 public constant BETA_SALE = 100; // TODO: take this into account with the paymentManager
    uint256 public constant ANIMATION_COUNT = 19;
    uint256 public constant SCHEME_COUNT = 8;
    address payable constant artmuseum = 0x027Fb48bC4e3999DCF88690aEbEBCC3D1748A0Eb; //lolz

    // mapping to store all the boxes in
    mapping(uint256 => TinyBox) internal boxes;

    // Create role identifiers
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    bytes32 public constant ANIMATOR_ROLE = keccak256("ANIMATOR_ROLE");
    bytes32 public constant TREASURER_ROLE = keccak256("TREASURER_ROLE");

    /**
     * @dev Contract constructor.
     * @notice Constructor inherits ERC721
     */
    constructor() public ERC721("TinyBoxes", "[#][#]") {
        // TODO: setup better roles befor launch
        // Grant all roles to the account deploying this contract for testing
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(ARTIST_ROLE, msg.sender);
        _setupRole(ANIMATOR_ROLE, msg.sender);
        _setupRole(TREASURER_ROLE, msg.sender);
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
     * @dev return list of animation titles
     * @return animationTitles list
     */
    function animationTitlesList()
        external
        view
        returns (string memory)
    {
        return '"Rounding Corners","Grow n Shrink","Squash n Stretch","Skew X","Skew Y","Snap Spin 1","Snap Spin 2","Snap Spin 3","Snap Spin 4","Spread","Spread Over Time","Glide","Uniform Speed Spin","2 Speed Spin","Indexed Spin","Jitter","Giggle","Jolt","Drop"';
    }

    /**
     * @dev return list of scheme titles
     * @return schemeTitles list
     */
    function schemeTitlesList()
        external
        view
        returns (string memory)
    {
        return '"Complimentary","Analogous","Split Complimentary","Triadic","Complimentary and Analogous","Analogous and Complimentary","Square","Tetradic"';
    }

    /**
     * @dev Lookup all token data in one call
     * @param _id for which we want token data
     * @return randomness provided by Chainlink VRF
     * @return animation of token
     * @return shapes of token
     * @return hatching of token
     * @return palette of token
     * @return size of token
     * @return spacing of token
     * @return mirrorPositions of token
     * @return scale of token
     */
    function tokenData(uint256 _id)
        external
        view
        returns (
            uint256 randomness,
            uint8 animation,
            uint8 shapes,
            uint16 hatching,
            uint16[6] memory palette,
            uint16[4] memory size,
            uint16[4] memory spacing,
            int16[3] memory mirrorPositions,
            uint16 scale
        )
    {
        TinyBox memory box = boxes[_id];
        randomness = box.randomness;
        animation = box.animation;
        shapes = box.shapes;
        hatching = box.hatching;
        palette = [
            box.colorPalette.hue,
            box.colorPalette.saturation,
            box.colorPalette.lightnessRange[0],
            box.colorPalette.lightnessRange[1],
            box.colorPalette.scheme,
            box.colorPalette.shades
        ];
        size = box.size;
        spacing = box.spacing;
        mirrorPositions = box.mirrorPositions;
        scale = box.scale;
    }
}
