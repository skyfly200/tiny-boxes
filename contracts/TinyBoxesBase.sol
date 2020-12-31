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
    uint256 public constant SCHEME_COUNT = 10;
    address payable constant artmuseum = 0x027Fb48bC4e3999DCF88690aEbEBCC3D1748A0Eb; //lolz

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
            uint8[4] memory mirroring,
            uint16[3] memory color,
            uint8 contrast,
            uint8 shades,
            uint8 scheme
        )
    {
        TinyBox memory box = boxes[_id];

        // TODO - generate animation with RNG weighted non uniformly for varying rarity types
        animation = boxRand[_id] % ANIMATION_COUNT;
        shades = uint8(boxRand[_id] % 8) + 1;
        scheme = uint8(_id.div(1000));
        shapes = box.shapes;
        hatching = box.hatching;
        color = [box.color.hue, box.color.saturation, box.color.lightness];
        contrast = box.contrast;
        size = box.size;
        spacing = box.spacing;
        mirroring = box.mirroring;
    }
}
