//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;

// needed for upgradability
//import "@openzeppelin/upgrades/contracts/Initializable.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./TinyBoxes.sol";

contract TinyBoxesBase is ERC721 {
    using Counters for Counters.Counter;

    Counters.Counter internal _tokenIds;

    uint256 public constant TOKEN_LIMIT = 1024;
    uint256 public constant ARTIST_PRINTS = 0;
    uint256 public constant ANIMATION_COUNT = 5;
    address public animator;
    address public deployer;
    address payable artmuseum = 0x027Fb48bC4e3999DCF88690aEbEBCC3D1748A0Eb; //lolz

    mapping(uint256 => TinyBox) internal boxes;

    /**
     * @dev Contract constructor.
     * @notice Constructor inherits VRFConsumerBase
     */
    constructor(address _animator) public ERC721("TinyBoxes", "[#][#]") {
        deployer = msg.sender;
        animator = _animator;
    }

    /**
     * @dev Lookup the seed
     * @param _id for which we want the seed
     * @return seed value of _id.
     */
    function tokenSeed(uint256 _id) external view returns (uint256) {
        return boxes[_id].seed;
    }

    /**
     * @dev Lookup the animation
     * @param _id for which we want the animation
     * @return animation value of _id.
     */
    function tokenAnimation(uint256 _id) external view returns (uint256) {
        return boxes[_id].animation;
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
