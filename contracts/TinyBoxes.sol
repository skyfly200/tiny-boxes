// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "./TinyBoxesStore.sol";

interface Renderer {
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
     * @dev update the Renderer to a new contract
     */
    function updateRenderer(address _renderer) external {
        onlyRole(ADMIN_ROLE);
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
        return renderer.perpetualRenderer(box, _id, ownerOf(_id), calcedParts(box, _id), "");
    }

    /**
     * @dev Generate the token SVG art with specific options
     * @param _id for which we want art
     * @param bkg for the token
     * @param duration animation duration modifier
     * @param options bits - 0th is the animate switch to turn on or off animation
     * @param slot string for embeding custom additions
     * @return animated SVG art of token
     */
    function tokenArt(uint256 _id, uint8 bkg, uint8 duration, uint8 options, string calldata slot)
        external
        view
        returns (string memory)
    {
        TinyBox memory box = boxes[_id];
        box.bkg = bkg;
        box.options = options;
        box.duration = duration;
        return renderer.perpetualRenderer(box ,_id, ownerOf(_id), calcedParts(box, _id), slot);
    }
    
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
    function renderPreview(
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
        validateParams(shapes[0], shapes[1], color, size, spacing, true);
        TinyBox memory box = TinyBox({
            randomness: uint128(seed.stringToUint()),
            hue: color[0],
            saturation: uint8(color[1]),
            lightness: uint8(color[2]),
            shapes: shapes[0],
            hatching: shapes[1],
            widthMin: size[0],
            widthMax: size[1],
            heightMin: size[2],
            heightMax: size[3],
            spread: spacing[0],
            mirroring: mirroring,
            grid: spacing[1],
            bkg: settings[0],
            duration: settings[1],
            options: settings[2]
        });
        return renderer.perpetualRenderer(box, 0, address(0), traits, slot);
    }
}
