//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./structs/Decimal.sol";
import "./structs/Shape.sol";
import "./structs/Modulation.sol";
import "./structs/TinyBox.sol";

import "./libraries/SVGBuffer.sol";
import "./libraries/Random.sol";
import "./libraries/Decimal.sol";
import "./libraries/StringUtilsLib.sol";

library TinyBoxesRenderer {
    using Math for uint256;
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using StringUtilsLib for *;
    using SVGBuffer for bytes;
    using Random for bytes32[];
    using DecimalUtils for Decimal;

    uint256 public constant ANIMATION_FRAME_RATE = 12;
    uint256 public constant ANIMATION_SECONDS = 10;
    uint256 public constant ANIMATION_FRAMES = ANIMATION_FRAME_RATE * ANIMATION_SECONDS;

    /**
     * @dev render the header of the SVG markup
     * @return header string
     */
    function _generateHeader() internal view returns (string memory) {
        bytes memory buffer = new bytes(8192);

        string memory xmlVersion = '<?xml version="1.0" encoding="UTF-8"?>';
        string memory doctype = '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">';
        string memory openingTag = '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="100%" height="100%" viewBox="0 0 2400 2400" style="stroke-width:0;background-color:#121212">';
        string memory symbols = '<symbol id="quad3"><symbol id="quad2"><symbol id="quad1"><symbol id="quad0">';

        buffer.append(xmlVersion);
        buffer.append(doctype);
        buffer.append(openingTag);
        buffer.append(symbols);

        return buffer.toString();
    }

    /**
     * @dev render the footer string for mirring effects
     * @param switches for each mirroring stage
     * @param mirrorPositions for generator settings
     * @param scale for each mirroring stage
     * @return footer string
     */
    function _generateFooter(
        bool[3] memory switches,
        Decimal[3] memory mirrorPositions,
        Decimal memory scale
    ) internal view returns (string memory) {
        bytes memory buffer = new bytes(8192);

        string[3] memory scales = ['-1 1', '-1 -1', '1 -1'];
        string[7] memory template = [
            '<g>',
            '<g transform="scale(',
            ') translate(',
            ')">',
            '<use xlink:href="#quad',
            '"/></g>',
            '</symbol>'
        ];

        for (uint256 s = 0; s < 3; s++) {
            // loop through mirroring effects
            buffer.append(template[6]);

            if (!switches[s]) {
                // turn off this level of mirroring
                // add a scale transform
                buffer.append(template[0]);
                // denote what quad the transform should be used for
                buffer.append(template[4]);
                if (s > 0) // TODO: remove and make quad names consistent
                    buffer.append(Strings.toString(uint256(s + 1)));
                buffer.append(template[5]);
            } else {
                string memory value = mirrorPositions[s].toString();
                for (uint8 i = 0; i < 4; i++) {
                    // loop through transforms
                    if (i == 0) buffer.append(template[0]);
                    else {
                        buffer.append(template[1]);
                        buffer.append(scales[i - 1]);
                        buffer.append(template[2]);
                        if (i <= 2) buffer.append('-');
                        buffer.append(i <= 2 ? value : '0');
                        buffer.append(' ');
                        if (i >= 2) buffer.append('-');
                        buffer.append(i >= 2 ? value : '0');
                        buffer.append(template[3]);
                    }
                    // denote what quad the transforms should be used for
                    buffer.append(template[4]);
                    buffer.append(Strings.toString(s));
                    buffer.append(template[5]);
                }
            }
        }
        // add final scaling
        buffer.append(template[6]);
        buffer.append(template[1]);
        buffer.append(scale.toString());
        buffer.append(' ');
        buffer.append(scale.toString());
        buffer.append(template[3]);
        buffer.append(template[4]);
        buffer.append('3');
        buffer.append(template[5]);

        buffer.append("</svg>"); // add closing svg tag
        return SVGBuffer.toString(buffer);
    }

    /**
     * @dev generate a color
     * @param pool randomn numbers
     * @return color value
     */
    function _generateColor(bytes32[] memory pool)
        internal
        pure
        returns (uint256)
    {
        uint256 red = uint256(pool.uniform(0x000012, 0x0000ff));
        uint256 green = uint256(pool.uniform(0x000012, 0x0000ff) * 256);
        uint256 blue = uint256(
            pool.uniform(0x000012, 0x0000ff) * 65536
        );
        uint256 colorscheme = uint256(pool.uniform(0, 99));

        if (colorscheme < 7) {
            return blue; // blue
        } else if (colorscheme < 14) {
            return green; // green
        } else if (colorscheme < 21) {
            return red; // red
        } else if (colorscheme < 35) {
            return green.add(blue); // cyan
        } else if (colorscheme < 49) {
            return red.add(blue); // magenta
        } else if (colorscheme < 63) {
            return red.add(green); // yellow
        } else if (colorscheme < 66) {
            uint256 brightness = uint256(
                pool.uniform(0x000022, 0x0000ee)
            ); // random greys
            return brightness.mul(65536).add(brightness.mul(256)).add(brightness);
        } else {
            return blue;
        }
    }

    /**
     * @dev generate a shape
     * @param pool randomn numbers
     * @param spacing for shapes
     * @param size of shapes
     * @param hatch mode on
     * @return positions of shape
     */
    function _generateBox(
        bytes32[] memory pool,
        uint16[4] memory spacing,
        uint16[4] memory size,
        bool hatch
    )
        internal
        pure
        returns (int256[2] memory positions, int256[2] memory dimensions)
    {
        positions = [
            pool.uniform(-(int256(spacing[0])), int256(spacing[0])) +
                ((pool.uniform(0, int256(spacing[2]).sub(1)).mul(800)).div(
                    int256(spacing[2]))),
            pool.uniform(-(int256(spacing[1])), int256(spacing[1])) +
                ((pool.uniform(0, int256(spacing[3]).sub(1)).mul(800)).div(
                    int256(spacing[3])))
        ];
        if (hatch) {
            int256 horizontal = pool.uniform(0, 1);
            // 		size[0] = uint(pool.uniform(dials[4], dials[5])) + horizontal * uint(dials[6]);
            //      size[1] = uint(dials[6]) + uint(dials[5])  - size[0] + uint256(pool.uniform(dials[7], dials[4]));
            int256 width = pool.uniform(25, 40).add(int256(700).mul(horizontal));
            dimensions = [
                width,
                pool.uniform(10, 25).add(int256(740).sub(width))
            ];
        } else
            dimensions = [
                pool.uniform(int256(size[0]), int256(size[1])),
                pool.uniform(int256(size[2]), int256(size[3]))
            ];
    }

    /**
     * @dev create a shape from provided box and mod parameters
     * @return shape struct
     */
    function _generateShape(
        int256 index,
        bytes32[] memory pool,
        uint256[] memory colorValues,
        TinyBox memory box,
        Modulation memory mod
    ) internal pure returns (Shape memory) {
        // modulate box generator input parameters
            for (uint256 j = 0; j < 4; j++) {
                box.spacing[j] = uint16(
                    uint256(box.spacing[j]).add(mod.spacing[j])
                );
                box.size[j] = uint16(
                    uint256(box.size[j]).add(mod.sizeRange[j])
                );
            }
            // pick a random color from the generated colors list
            // and modulate selected color indexes
            int256 colorCount = int256(box.colors);
            uint256 color = colorValues[
                uint256(pool.uniform(0, colorCount.sub(1)).add(mod.color))
                .mod(uint256(colorCount))];
            // offset hatching index start by hatch modulator
            bool hatching = (box.hatching > 0 &&
                uint256(index.add(mod.hatch)).mod(box.hatching) == 0);
            // generate a shapes position and size using box parameters
            (
                int256[2] memory positionGen,
                int256[2] memory sizeGen
            ) = _generateBox(pool, box.spacing, box.size, hatching);
            // convert generated shape values to decimal and modulate the shape position and size
            Decimal[2] memory position;
            Decimal[2] memory size;
            position[0] = Decimal(positionGen[0], 0).add(mod.position[0]);
            position[1] = Decimal(positionGen[1], 0).add(mod.position[1]);
            size[0] = Decimal(sizeGen[0], 0).add(mod.size[0]);
            size[1] = Decimal(sizeGen[1], 0).add(mod.size[1]);
            // modulate the corner radius
            uint256 radius = mod.radius;
            // modulate the opacity
            return Shape(position, size, mod.opacity, radius, color);
    }

    /**
     * @dev calculate the animation modulators for a shape
     * @param box object to base modulations around
     * @param frame number being rendered
     * @param shape index being modulated
     * @return mod struct of modulator values
     */
    function _calculateMods(
        TinyBox memory box,
        uint256 frame,
        uint256 shape
    ) internal pure returns (Modulation memory mod) {
        // set animation modifiers to default
        mod = Modulation({
            color: int256(0),
            hatch: int256(0),
            stack: int256(0),
            spacing: [0, 0, 0, 0],
            sizeRange: [0, 0, 0, 0],
            position: [Decimal(0, 5), Decimal(0, 5)],
            size: [Decimal(0, 5), Decimal(0, 5)],
            mirror: [Decimal(0, 2), Decimal(0, 2), Decimal(0, 2)],
            opacity: Decimal(100, 2),
            radius: uint256(0)
        });
        // apply animation based on animation, frame and shape values
        uint256 animation = box.animation;
        if (animation == 0) {
            // shift the shapes color indexes
            mod.color = uint8(frame);
        } else if (animation == 1) {
            // shift the starting index of hatched shapes
            mod.hatch = uint8(frame);
        } else if (animation == 2) {
            // shift the stacking order of the shapes
            mod.stack = uint8(frame);
        } else if (animation == 3) {
            // shift mirror position 0
            mod.mirror[0] = Decimal(int256(frame), 0);
        } else if (animation == 4) {
            // squash and squeze
            // transfer height to width and vice versa
            int256 change;
            if (frame < ANIMATION_FRAMES / 2)
                change = int256(shape.add(frame).sub(uint256(box.shapes).div(2)).mod(uint256(box.shapes)));
            else
                change = int256(shape.add(uint256(box.shapes).div(2)).sub(frame.sub(ANIMATION_FRAMES / 2)).mod(uint256(box.shapes)));
            mod.size[0] = Decimal(change, 0);
            mod.size[1] = Decimal(change.mul(int256(-1)), 0);
        }
    }

    /**
     * @dev render a token's art
     * @param box TinyBox data structure
     * @param frame number to render
     * @return markup of the SVG graphics of the token
     */
    function perpetualRenderer(TinyBox memory box, uint256 frame)
        public
        view
        returns (bytes memory)
    {
        // --- Calculate Generative Shape Data ---

        // initilize RNG with the provided randomness
        bytes32[] memory pool = Random.init(box.randomness);

        // generate colors
        uint256[] memory colorValues = new uint256[](box.colors);
        for (uint256 i = 0; i < box.colors; i++)
            colorValues[i] = _generateColor(pool);

        // generate an array of shapes
        uint256 shapeCount = box.shapes;
        Shape[] memory shapes = new Shape[](shapeCount);
        Modulation memory mod;
        for (uint256 i = 0; i < shapeCount; i++) {
            // calculate the animation modulators based on frames and animation id
            mod = _calculateMods(box, frame, i);
            // generate a new shape
            shapes[i] = _generateShape(int256(i), pool, colorValues, box, mod);
        }

        // --- Render SVG Markup ---

        // empty buffer for the SVG markup
        bytes memory buffer = new bytes(8192);

        // write the document header to the SVG
        buffer.append(_generateHeader());

        // write shapes to the SVG
        for (int256 i = 0; i < int256(shapeCount); i++) {
            Shape memory shape = shapes[uint256(i.add(mod.stack)).mod(shapeCount)];
            SVGBuffer.rect(
                buffer,
                shape.position,
                shape.size,
                shape.opacity,
                shape.radius,
                shape.color
            );
        }

        // convert scale to decimal
        Decimal memory scale = Decimal(box.scale, 100);

        // modulate the mirror values
        Decimal[3] memory mirrorPositions;
        for (uint256 i = 0; i < 3; i++)
            mirrorPositions[i] = Decimal(box.mirrorPositions[i], 0).add(mod.mirror[i]);

        // write the footer to the SVG
        SVGBuffer.append(
            buffer,
            _generateFooter(
                box.mirrors,
                mirrorPositions,
                scale
            )
        );

        return buffer;
    }
}
