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
     * @param mod of the frame
     * @param colors list of colors
     * @return positions of shape
     */
    function _generateShape(
        bytes32[] memory pool,
        uint256 index,
        TinyBox memory box,
        Modulation memory mod,
        HSL[] memory colors
    )
        internal
        pure
        returns (Shape memory)
    {
        // offset hatching index start by hatch modulator
        bool hatching = (
            box.hatching > 0 &&
            uint256(int256(index).add(mod.hatch)).mod(box.hatching) == 0
        );
        // generate a shapes position and size using box parameters
        (
            int256[2] memory position,
            int256[2] memory size
        ) = _generateBox(pool, box.spacing, box.size, hatching);
        // pick a random color from the generated colors list
        // and modulate selected color
        int256 selection = pool.uniform(0, int256(uint256(colors.length) - 1));
        HSL memory color = colors[
            uint256(selection.add(mod.color))
            .mod(uint256(colors.length))
        ];
        return Shape(position, size, color);
    }

    /**
     * @dev calculate the frame level animation modulators
     * @param box object to base modulations around
     * @param frame number being rendered
     * @return mod struct of modulator values
     */
    function _calculateMods(
        TinyBox memory box,
        uint256 frame
    ) internal pure returns (Modulation memory mod) {
        // set animation modifiers to default
        mod = Modulation({
            color: int256(0),
            hatch: int256(0),
            stack: int256(0),
            mirror: [int256(0).toDecimal(2), int256(0).toDecimal(2), int256(0).toDecimal(2)]
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
            mod.mirror[0] = int256(frame).toDecimal(2);
        }
    }

    /**
     * @dev calculate the modulators for a shape
     * @param box object to base modulations around
     * @param frame number being rendered
     * @param shape index being modulated
     * @return mod struct of modulator values
     */
    function _calculateShapeMods(
        Shape memory shape,
        TinyBox memory box,
        uint256 frame,
        uint256 shapeIndex
    ) internal pure returns (ShapeModulation memory mod) {
        // set animation modifiers to default
        mod = ShapeModulation({
            rotation: int256(0).toDecimal(2),
            origin: [int256(0).toDecimal(3), int256(0).toDecimal(3)],
            offset: [int256(0).toDecimal(3), int256(0).toDecimal(3)],
            scale: [int256(1000).toDecimal(3), int256(1000).toDecimal(3)],
            skew: [int256(0).toDecimal(3), int256(0).toDecimal(3)],
            opacity: int256(100).toDecimal(2),
            radius: uint256(0)
        });
        // apply animation based on animation, frame and shape values
        uint256 animation = box.animation;
        if (animation == 4) {
            // squash and squeze
            // transfer height to width and vice versa
            // int256 change;
            // if (frame < ANIMATION_FRAMES / 2)
            //     change = int256(shapeIndex.add(frame).sub(uint256(box.shapes).div(2)).mod(uint256(box.shapes)));
            // else
            //     change = int256(shapeIndex.add(uint256(box.shapes).div(2)).sub(frame.sub(ANIMATION_FRAMES / 2)).mod(uint256(box.shapes)));
            // mod.scale[0] = int256(change).toDecimal();
            // mod.scale[1] = int256(change.mul(int256(-1))).toDecimal();
        } else if (animation == 5) {
            // skew x
            int256 amp = 1;
            int256 s = int256(
                amp.mul(int256(frame))
                //shape.size[0]
                //.add(int256(shapeIndex).sub(int256(box.shapes / 2))))
            );
            mod.skew[0] = s.toDecimal(0);
        } else if (animation == 6) {
            // slide
            int256 amp = 5;
            int256 s = int256(
                amp.mul(int256(frame))
                //.add(int256(shapeIndex).sub(int256(box.shapes / 2)))
            );
            mod.offset[0] = s.toDecimal(0);
        } else if (animation == 7) {
            // spin
            uint256 angle = uint256(360).div(ANIMATION_FRAMES);
            int256 s = int256(angle.mul(frame));
            mod.rotation = s.toDecimal(0);
        } else if (animation == 8) {
            // opacity
            uint256 step = uint256(1000).div(ANIMATION_FRAMES);
            uint256 p;
            if (frame < ANIMATION_FRAMES.div(2)) p = frame; // first half
            else p = ANIMATION_FRAMES.sub(frame);
            uint256 alpha = uint256(1000).sub(step.mul(p));
            mod.opacity = int256(alpha).toDecimal(3);
        } else if (animation == 9) {
            // rounded corners
            // find shorter shape dimension
            // modulate the shapes radius by that amount
            uint256 d = Math.min(uint256(shape.size[0]), uint256(shape.size[1]));
            uint256 step = uint256(d).div(ANIMATION_FRAMES);
            uint256 p;
            if (frame < ANIMATION_FRAMES.div(2)) p = frame; // first half
            else p = ANIMATION_FRAMES.sub(frame);
            uint256 radius = step.mul(p);
            mod.radius = radius;
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
        // TODO: use generate scheme params
        // hue, sat, light, scheme, shades
        HSL memory root = HSL(305,100,80);
        uint8 scheme = 3;
        //HSL[] memory colors2 = Colors.generateScheme(root, scheme, 0);
        HSL[] memory colors = new HSL[](14);
        colors[0] = Colors.lookupColor(root,scheme,0,-1);
        colors[1] = Colors.lookupColor(root,scheme,0,0);
        colors[2] = Colors.lookupColor(root,scheme,0,1);
        colors[3] = Colors.lookupColor(root,scheme,1,-1);
        colors[4] = Colors.lookupColor(root,scheme,1,0);
        colors[5] = Colors.lookupColor(root,scheme,1,1);
        colors[6] = Colors.lookupColor(root,scheme,2,-2);
        colors[7] = Colors.lookupColor(root,scheme,2,-1);
        colors[8] = Colors.lookupColor(root,scheme,2,0);
        colors[9] = Colors.lookupColor(root,scheme,2,1);
        colors[10] = Colors.lookupColor(root,scheme,2,2);
        colors[11] = Colors.lookupColor(root,scheme,3,-1);
        colors[12] = Colors.lookupColor(root,scheme,3,0);
        colors[13] = Colors.lookupColor(root,scheme,3,1);

        // generate an array of shapes
        uint256 shapeCount = box.shapes;
        Shape[] memory shapes = new Shape[](shapeCount);
        ShapeModulation[] memory shapeMods = new ShapeModulation[](shapeCount);
        Modulation memory mod = _calculateMods(box, frame);
        for (uint256 i = 0; i < shapeCount; i++) {
            // generate a new shape
            shapes[i] = _generateShape(pool, i, box, mod, colors);
            // calculate the shape modulation based on box data, frame and shape #
            shapeMods[i] = _calculateShapeMods(shapes[i], box, frame, i);
        }

        // --- Render SVG Markup ---

        // empty buffer for the SVG markup
        bytes memory buffer = new bytes(8192);

        // write the document header to the SVG
        buffer.append(SVG._generateHeader());
        buffer.append(SVG._generateBody(box));

        // write shapes to the SVG
        for (int256 i = 0; i < int256(shapeCount); i++) {
            uint256 shapeIndex = uint256(i.add(mod.stack)).mod(shapeCount);
            buffer.append(SVG._rect(box, uint256(i), shapes[shapeIndex], shapeMods[shapeIndex], true)); // animated flag at end
        }

        // convert master box scale to decimal with a precision of two digits
        Decimal memory scale = int256(box.scale).toDecimal(2);

        // modulate the mirror values
        bool[3] memory mirrors = box.mirrors;
        int16[3] memory mirrorPositionsIn = box.mirrorPositions;
        Decimal[3] memory mirrorPositions;
        for (uint256 i = 0; i < 3; i++)
            mirrorPositions[i] = mirrorPositionsIn[i].toDecimal(2, 0).add(mod.mirror[i]);

        // write the footer to the SVG
        buffer.append(
            SVG._generateFooter(
                mirrors,
                mirrorPositions,
                scale
            )
        );

        return buffer;
    }
}
