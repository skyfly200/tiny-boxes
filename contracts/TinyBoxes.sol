//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "./TinyBoxesStore.sol";
import "./TinyBoxesRenderer.sol";

contract TinyBoxes is TinyBoxesStore {
    using TinyBoxesRenderer for TinyBox;

    /**
     * @dev Contract constructor.
     * @notice Constructor inherits from TinyBoxesStore
     */
    constructor(address rand)
        public
        TinyBoxesStore(rand)
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
     * @param id of the token to preview
     * @param seed for renderer RNG
     * @param shapes count
     * @param hatching mod
     * @param color settings (hue, sat, light, contrast, shades)
     * @param size for shapes
     * @param spacing grid and spread
     * @param traits mirroring, scheme, shades, animation
     * @param animate switch to turn on or off animation
     * @return preview SVG art
     */
    function tokenPreview(
        string memory seed,
        uint8 shapes,
        uint8 hatching,
        uint16[4] memory color,
        uint8[4] memory size,
        uint8[2] memory spacing,
        uint8[5] memory traits,
        bool animate,
        uint256 id
    ) public view returns (string memory) {
        validateParams(shapes, hatching, color, size, spacing);
        TinyBox memory box = TinyBox({
            color: HSL(color[0],uint8((id.mod(phaseLen) < phaseLen.sub(5)) ? color[1] : 0),uint8(color[2])),
            contrast: uint8(color[3]),
            shapes: shapes,
            hatching: hatching,
            size: size,
            spacing: spacing,
            mirroring: traits[0],
            scheme: traits[1],
            shades: traits[2],
            animation: traits[3]
        });
        return box.perpetualRenderer(seed.stringToUint(), animate, [traits[4], id], address(0));
    }

    /**
     * @dev Generate the token SVG art of a specified frame
     * @param _id for which we want art
     * @param animate switch to turn on or off animation
     * @param bkg for the token
     * @return animated SVG art of token _id at _frame.
     */
    function tokenArt(uint256 _id, bool animate, uint8 bkg)
        public
        view
        returns (string memory)
    {
        TinyBox memory box = boxes[_id];
        uint256 randomness = boxRand[_id];
        return box.perpetualRenderer(randomness, animate, [bkg, _id], ownerOf(_id));
    }
}
