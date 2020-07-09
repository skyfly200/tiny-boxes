//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;

// needed for upgradability
//import "@openzeppelin/upgrades/contracts/Initializable.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./TinyBoxes.sol";

contract TinyBoxesBase is ERC721, AccessControl  {
    using Counters for Counters.Counter;

    Counters.Counter internal _tokenIds;

    // set contract config constants
    uint256 public constant TOKEN_LIMIT = 1024;
    uint256 public constant ARTIST_PRINTS = 0;
    uint256 public constant ANIMATION_COUNT = 5;
    address payable constant artmuseum = 0x027Fb48bC4e3999DCF88690aEbEBCC3D1748A0Eb; //lolz

    // mapping to store all the boxes in
    mapping(uint256 => TinyBox) internal boxes;

    // Create role identifiers
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant ANIMATOR_ROLE = keccak256("ANIMATOR_ROLE");
    bytes32 public constant TREASURER_ROLE = keccak256("TREASURER_ROLE");

    /**
     * @dev Contract constructor.
     * @notice Constructor inherits ERC721
     */
    constructor() public ERC721("TinyBoxes", "[#][#]") {
        // Grant all roles to the account deploying this contract
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(ANIMATOR_ROLE, msg.sender);
        _setupRole(TREASURER_ROLE, msg.sender);
    }

    /**
     * @dev Lookup all token data in one call
     * @param _id for which we want token data
     * @return seed of token
     * @return randomness provided by Chainlink VRF
     * @return animation of token
     * @return colors of token
     * @return shapes of token
     * @return hatching of token
     * @return size of token
     * @return spacing of token
     * @return mirrorPositions of token
     * @return mirrors of token
     * @return scale of token
     */
    function tokenData(uint256 _id)
        external
        view
        returns (
            uint256 seed,
            uint256 randomness,
            uint8 animation,
            uint8 colors,
            uint8 shapes,
            uint16 hatching,
            uint16[4] memory size,
            uint16[4] memory spacing,
            int16[3] memory mirrorPositions,
            bool[3] memory mirrors,
            uint16 scale
        )
    {
        TinyBox memory box = boxes[_id];
        seed = box.seed;
        randomness = box.randomness;
        animation = box.animation;
        colors = box.colors;
        shapes = box.shapes;
        hatching = box.hatching;
        size = box.size;
        spacing = box.spacing;
        mirrorPositions = box.mirrorPositions;
        mirrors = box.mirrors;
        scale = box.scale;
    }
}
