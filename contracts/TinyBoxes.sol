//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "./TinyBoxesStore.sol";
import "./TinyBoxesRenderer.sol";

contract TinyBoxes is TinyBoxesStore {
    using TinyBoxesRenderer for TinyBox;

    /**
     * @dev Contract constructor.
     * @param _link address of the LINK token
     * @param _feed address of the LINK/ETH price feed
     * @notice Constructor inherits from TinyBoxesStore
     */
    constructor(
        address _link,
        address _feed
    )
        public
        TinyBoxesStore(_link, _feed)
    {}

    /**
     * @dev Set the tokens URI
     * @param _id of a token to update
     * @param _uri for the token
     * @dev Only the animator role can call this
     */
    function setTokenURI(uint256 _id, string calldata _uri)
        external
        onlyRole(ANIMATOR_ROLE)
    {
        _setTokenURI(_id, _uri);
    }

    /**
     * @dev Update the base URI field
     * @param _uri base for all tokens 
     * @dev Only the admin role can call this
     */
    function setBaseURI(string calldata _uri)
        external
        onlyRole(ADMIN_ROLE)
    {
        _setBaseURI(_uri);
    }

    /**
     * @dev Generate the token SVG art preview for given parameters
     * @param _seed for renderer RNG
     * @param shapes count
     * @param hatching mod
     * @param color settings (hue, sat, light, contrast, shades)
     * @param size for shapes
     * @param spacing grid and spread
     * @param mirroring positions and scale
     * @param animate switch to turn on or off animation
     * @return preview SVG art
     */
    function tokenPreview(
        string memory _seed,
        uint8 shapes,
        uint8 hatching,
        uint16[4] memory color,
        uint8[4] memory size,
        uint8[2] memory spacing,
        uint8[4] memory mirroring,
        bool animate
    ) public view returns (string memory) {
        TinyBox memory box = TinyBox({
            shapes: shapes,
            hatching: hatching,
            color: HSL(color[0],uint8(color[1]),uint8(color[2])),
            contrast: uint8(color[3]),
            size: size,
            spacing: spacing,
            mirroring: mirroring
        });
        return box.perpetualRenderer(_seed.stringToUint(), animate, _tokenIds.current(), address(0));
    }

    /**
     * @dev Generate the token SVG art of a specified frame
     * @param _id for which we want art
     * @param animate switch to turn on or off animation
     * @return animated SVG art of token _id at _frame.
     */
    function tokenArt(uint256 _id, bool animate)
        public
        view
        returns (string memory)
    {
        TinyBox memory box = boxes[_id];
        uint256 randomness = boxRand[_id];
        return box.perpetualRenderer(randomness, animate, _id, ownerOf(_id));
    }
}
