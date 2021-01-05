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
    uint16 public constant TOKEN_LIMIT = 10000;
    uint8 public constant ARTIST_PRINTS = 0; // TODO: set to 2 for launch, test in beta
    uint8 public constant BETA_SALE = 100; // TODO: take this into account with the paymentManager
    uint8 public constant ANIMATION_COUNT = 24;
    uint8 public constant SCHEME_COUNT = 10;

    // mapping to store all the boxes info
    mapping(uint256 => TinyBox) internal boxes;
    mapping(uint256 => uint256) internal boxRand;

    // Create role identifiers
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    bytes32 public constant ANIMATOR_ROLE = keccak256("ANIMATOR_ROLE");

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
            uint8[2] memory mirroring,
            uint16[3] memory color,
            uint8 contrast,
            uint8 shades,
            uint8 scheme
        )
    {
        TinyBox memory box = boxes[_id];

        animation = box.animation;
        shades = box.shades;
        scheme = box.scheme;
        mirroring = box.mirroring;
        shapes = box.shapes;
        hatching = box.hatching;
        color = [box.color.hue, box.color.saturation, box.color.lightness];
        contrast = box.contrast;
        size = box.size;
        spacing = box.spacing;
    }
}
