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
    constructor(
        address _link,
        address _feed
    )
        public
        TinyBoxesStore(_link, _feed)
    {}

    /**
     * @dev Update the token URI field
     * @dev Only the animator role can call this
     */
    function updateURI(uint256 _id, string calldata _uri)
        external
        onlyRole(ANIMATOR_ROLE)
    {
        _setTokenURI(_id, _uri);
    }

    /**
     * @dev Generate the token SVG art preview for given parameters
     * @param _seed for renderer RNG
     * @param shapes count
     * @param palette for color selection
     * @param dials for perpetual renderer
     * @return preview SVG art
     */
    function tokenTest(
        string memory _seed,
        uint8 shapes,
        uint16[6] memory palette,
        int16[13] memory dials,
        uint8 animation,
        bool animate
    ) public view returns (string memory) {
        TinyBox memory box = TinyBox({
            randomness: _seed.stringToUint(),
            animation: animation,
            shapes: shapes,
            colorPalette: Palette(palette[0],uint8(palette[1]),[uint8(palette[2]),uint8(palette[3])],uint8(palette[4]),uint8(palette[5])),
            spacing: [
                uint16(dials[0]),
                uint16(dials[1]),
                uint16(dials[2]),
                uint16(dials[3])
            ],
            size: [
                uint16(dials[4]),
                uint16(dials[5]),
                uint16(dials[6]),
                uint16(dials[7])
            ],
            hatching: uint16(dials[8]),
            mirrorPositions: [dials[9], dials[10], dials[11]],
            scale: uint16(dials[12])
        });
        return box.perpetualRenderer(animate, int256(-1), '');
    }

    /**
     * @dev Generate the token SVG art of a specified frame
     * @param _id for which we want art
     * @return animated SVG art of token _id at _frame.
     */
    function tokenArt(uint256 _id, bool animate)
        public
        view
        returns (string memory)
    {
        TinyBox memory box = boxes[_id];
        string memory owner = string(abi.encodePacked(ownerOf(_id)));
        return box.perpetualRenderer(animate, int256(_id), owner);
    }
}
