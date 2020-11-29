//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./structs/Decimal.sol";
import "./structs/Shape.sol";
import "./structs/TinyBox.sol";
import "./structs/HSL.sol";

import "./libraries/SVGBuffer.sol";
import "./libraries/SVG.sol";
import "./libraries/Random.sol";
import "./libraries/Utils.sol";
import "./libraries/Decimal.sol";
import "./libraries/Colors.sol";
import "./libraries/StringUtilsLib.sol";

library TinyBoxesRenderer {
    using Math for uint256;
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using StringUtilsLib for *;
    using SVGBuffer for bytes;
    using Random for bytes32[];
    using DecimalUtils for *;
    using Utils for *;
    using Colors for *;
    using Strings for *;

    uint256 public constant ANIMATION_FRAME_RATE = 10;
    uint256 public constant ANIMATION_SECONDS = 3;
    uint256 public constant ANIMATION_FRAMES = ANIMATION_FRAME_RATE * ANIMATION_SECONDS;

    /**
     * @dev generate a shape
     * @param pool randomn numbers pool
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
     * @dev generate a shape
     * @param pool randomn numbers
     * @param index of the shape
     * @param box data to make a shape from
     * @param colors list of colors
     * @return positions of shape
     */
    function _generateShape(
        bytes32[] memory pool,
        uint256 index,
        TinyBox memory box,
        HSL[] memory colors
    )
        internal
        pure
        returns (Shape memory)
    {
        // calculate hatching switch
        bool hatching = (
            box.hatching > 0 &&
            uint256(index).mod(box.hatching) == 0
        );
        // generate a shapes position and size using box parameters
        (
            int256[2] memory position,
            int256[2] memory size
        ) = _generateBox(pool, box.spacing, box.size, hatching);
        // pick a random color from the generated colors list
        int256 selection = pool.uniform(0, int256(uint256(colors.length) - 1));
        HSL memory color = colors[
            uint256(selection)
        ];
        return Shape(position, size, color);
    }

    /**
     * @dev render a token's art
     * @param box TinyBox data structure
     * @return markup of the SVG graphics of the token as a string
     */
    function perpetualRendererStr(TinyBox memory box, bool animate)
        public
        view
        returns (string memory)
    {
        // --- Calculate Generative Shape Data ---
        bytes32[] memory pool = Random.init(box.randomness);
        HSL[] memory colors = Colors.generateColors(box.colorPalette);

        // --- Render SVG Markup ---
        string memory header = SVG._generateHeader();
        string memory metadata = SVG._generateMetadata(box);

        // generate shapes (+ animations)
        string memory shapes = "";
        for (uint256 i = 0; i < uint256(box.shapes); i++) {
            Shape memory shape = _generateShape(pool, i, box, colors);
            if (animate) {
                string memory animation = SVG._generateAnimation(box, shape, i);
                shapes = string(abi.encodePacked(shapes, SVG._rect(shape, animation)));
            } else
                shapes = string(abi.encodePacked(shapes, SVG._rect(shape)));
        }

        // generate the footer
        // TODO: rename to mirroring and reference shapes symbol
        string memory mirroring = SVG._generateMirroring(
            box.mirrorPositions,
            int256(box.scale).toDecimal(2)
        );

        return string(abi.encodePacked(header, metadata, '<defs><symbol id="shapes">', shapes, '</symbol></defs>',  mirroring, '</svg>'));
    }

    /**
     * @dev render a token's art
     * @param box TinyBox data structure
     * @return markup of the SVG graphics of the token
     */
    function perpetualRenderer(TinyBox memory box, bool animate)
        public
        view
        returns (bytes memory)
    {
        // --- Calculate Generative Shape Data ---
        bytes32[] memory pool = Random.init(box.randomness);
        HSL[] memory colors = Colors.generateColors(box.colorPalette);

        // --- Render SVG Markup ---
        // TODO - switch up to use abi.encodePacked(arg);
        bytes memory buffer = new bytes(100000);
        buffer.append(SVG._generateHeader());
        // TODO - pass slot in here with shapes, change footer to mirroring and add generateSVG
        buffer.append(SVG._generateMetadata(box));
        buffer.append(SVG._generateBody(box));

        // write shapes to the SVG
        for (uint256 i = 0; i < uint256(box.shapes); i++) {
            Shape memory shape = _generateShape(pool, i, box, colors);
            if (animate) {
                string memory animation = SVG._generateAnimation(box, shape, i);
                buffer.append(SVG._rect(shape, animation));
            } else
                buffer.append(SVG._rect(shape));
        }

        // write the footer to the SVG
        buffer.append(
            SVG._generateFooter(
                box.mirrorPositions,
                int256(box.scale).toDecimal(2)
            )
        );

        // close the svg tag
        buffer.append("</svg>");

        return buffer;
    }
}
