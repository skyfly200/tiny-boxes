//SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "./TinyBoxesStore.sol";

interface Renderer {
    function renderToken(
        string calldata seed,
        uint16[3] calldata color,
        uint8[2] calldata shapes,
        uint8[4] calldata size,
        uint8[2] calldata spacing,
        uint8 mirroring,
        uint8[3] calldata settings,
        uint8[4] calldata traits,
        string calldata slot
    ) external view returns (string memory);
    function perpetualRenderer(
        TinyBox calldata box,
        uint256 id,
        address owner,
        uint8[4] calldata dVals,
        string calldata _slot
    ) external view returns (string memory);
}

contract TinyBoxes is TinyBoxesStore {
    Renderer renderer;

    /**
     * @dev Contract constructor.
     * @notice Constructor inherits from TinyBoxesStore
     */
    constructor(address rand, address _renderer)
        public
        TinyBoxesStore(rand)
    {
        renderer = Renderer(_renderer);
    }

    /**
     * @dev Generate the token SVG art
     * @param _id for which we want art
     * @return SVG art of token 
     */
    function tokenArt(uint256 _id)
        external
        view
        returns (string memory)
    {
        TinyBox memory box = boxes[_id];
        //return renderer.renderToken(box.randomness,[box],[box.shapes,box.hatching],box.size,box.spacing,box.mirroring,box.settings,calcedParts(box, _id),"");
        return renderer.perpetualRenderer(box, _id, ownerOf(_id), calcedParts(box, _id), "");
    }

    // /**
    //  * @dev Generate the token SVG art with specific options
    //  * @param _id for which we want art
    //  * @param bkg for the token
    //  * @param duration animation duration modifier
    //  * @param options bits - 0th is the animate switch to turn on or off animation
    //  * @param slot string for embeding custom additions
    //  * @return animated SVG art of token
    //  */
    // function tokenArt(uint256 _id, uint8 bkg, uint8 duration, uint8 options, string calldata slot)
    //     external
    //     view
    //     returns (string memory)
    // {
    //     TinyBox memory box = boxes[_id];
    //     box.bkg = bkg;
    //     box.options = options;
    //     box.duration = duration;
    //     return renderer.perpetualRenderer(box ,_id, ownerOf(_id), calcedParts(box, _id), slot);
    // }
    
    /**
     * @dev Generate the token SVG art preview for given parameters
     * @param seed for renderer RNG
     * @param shapes count and hatching mod
     * @param color settings (hue, sat, light, contrast, shades)
     * @param size for shapes
     * @param spacing grid and spread
     * @param traits mirroring, scheme, shades, animation
     * @param settings adjustable render options - bkg, duration, options
     * @param slot string to enter at end of SVG markup
     * @return preview SVG art
     */
    function tokenPreview(
        string calldata seed,
        uint16[3] calldata color,
        uint8[2] calldata shapes,
        uint8[4] calldata size,
        uint8[2] calldata spacing,
        uint8 mirroring,
        uint8[3] calldata settings,
        uint8[4] calldata traits,
        string calldata slot
    ) external view returns (string memory) {
        require(settings[0] <= 101, "BKG % Invalid");
        validateParams(shapes[0], shapes[1], color, size, spacing, true);
        return renderer.renderToken(seed,color,shapes,size,spacing,mirroring,settings,traits,slot);
    }
}
