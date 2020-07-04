//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import {
    SafeMath as SafeMath_TinyBoxes
} from "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./Buffer.sol";
import "./Random.sol";

abstract contract TinyBoxesRenderer {
    using SafeMath_TinyBoxes for uint256;

    string header = '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">\n<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="100%" height="100%" viewBox="0 0 2600 2600" style="stroke-width:0; background-color:#121212;">\n\n<symbol id="upperleftquad4">\n<symbol id="upperleftquad3">\n<symbol id="upperleftquad2">\n<symbol id="upperleftquad">\n\n';
    string[3] scales = ["-1 1", "-1 -1", "1 -1"];
    string[7] template = [
        "\n<g>",
        '\n<g transform="scale(',
        ") translate(",
        ')">',
        '\n<use xlink:href="#upperleftquad',
        '"/>\n</g>',
        "\n</symbol>"
    ];

    struct TinyBox {
        uint256 seed;
        uint256 randomness;
        uint8 animation;
        uint8 shapes;
        uint8 colors;
        uint16 hatching;
        uint16 scale;
        int16[3] mirrorPositions;
        uint16[4] size;
        uint16[4] spacing;
        bool[3] mirrors;
    }

    struct Shape {
        int256[2] position;
        uint256[2] size;
        uint256 color;
        uint256 opacity;
    }

    struct Modulation {
        uint256 color;
        uint256 hatch;
        uint256 stack;
        uint8[4] spacing;
        uint8[4] sizeRange;
        uint8[2] position;
        uint8[2] size;
        uint8[3] mirror;
    }

    /**
     * @dev generate a color
     * @param pool randomn numbers
     * @param _id of token to render
     * @return color value
     */
    function _generateColor(bytes32[] memory pool, uint256 _id)
        internal
        pure
        returns (uint256)
    {
        uint256 red = uint256(Random.uniform(pool, 0x000012, 0x0000ff));
        uint256 green = uint256(Random.uniform(pool, 0x000012, 0x0000ff) * 256);
        uint256 blue = uint256(
            Random.uniform(pool, 0x000012, 0x0000ff) * 65536
        );
        uint256 colorscheme = uint256(Random.uniform(pool, 0, 99));

        if (_id == 0) {
            return 0x000000; // all black
        } else if (_id > 73 && _id < 80) {
            return uint256(0xffffff); // all white
        } else if (colorscheme < 7) {
            return blue;
        } else if (colorscheme < 14) {
            return green;
        } else if (colorscheme < 21) {
            return red;
        } else if (colorscheme < 35) {
            return green + blue;
        } else if (colorscheme < 49) {
            return red + blue;
        } else if (colorscheme < 63) {
            return red + green;
        } else if (colorscheme < 66) {
            uint256 brightness = uint256(
                Random.uniform(pool, 0x000022, 0x0000ee)
            ); // random greys
            return (brightness * 65536) + (brightness * 256) + brightness;
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
    function _generateShape(
        bytes32[] memory pool,
        uint16[4] memory spacing,
        uint16[4] memory size,
        bool hatch
    )
        internal
        pure
        returns (int256[2] memory positions, uint256[2] memory dimensions)
    {
        positions = [
            Random.uniform(pool, -(int256(spacing[0])), int256(spacing[0])) +
                ((Random.uniform(pool, 0, int256(spacing[2]) - 1) * 800) /
                    int256(spacing[2])),
            Random.uniform(pool, -(int256(spacing[1])), int256(spacing[1])) +
                ((Random.uniform(pool, 0, int256(spacing[3]) - 1) * 800) /
                    int256(spacing[3]))
        ];
        if (hatch) {
            uint256 horizontal = uint256(Random.uniform(pool, 0, 1));
            // 		size[0] = uint(Random.uniform(pool, dials[4], dials[5])) + horizontal * uint(dials[6]);
            //      size[1] = uint(dials[6]) + uint(dials[5])  - size[0] + uint256(Random.uniform(pool, dials[7], dials[4]));
            uint256 width = uint256(Random.uniform(pool, 25, 40)) +
                uint256(700 * horizontal);
            dimensions = [
                width,
                uint256(Random.uniform(pool, 10, 25)) + uint256(740 - width)
            ];
        } else
            dimensions = [
                uint256(Random.uniform(pool, int256(size[0]), int256(size[1]))),
                uint256(Random.uniform(pool, int256(size[2]), int256(size[3])))
            ];
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
        int16[3] memory mirrorPositions,
        uint16 scale
    ) internal view returns (string memory footer) {
        bytes memory buffer = new bytes(8192);

        for (uint8 s = 0; s < 3; s++) {
            // loop through mirroring effects
            Buffer.append(buffer, template[6]);

            if (!switches[s]) {
                // turn off this level of mirroring
                // add a scale transform
                Buffer.append(buffer, template[0]);
                // denote what quad the transform should be used for
                Buffer.append(buffer, template[4]);
                if (s > 0)
                    Buffer.append(buffer, Strings.toString(uint256(s + 1)));
                Buffer.append(buffer, template[5]);
            } else {
                string memory value = Strings.toString(
                    uint256(mirrorPositions[s])
                );
                for (uint8 i = 0; i < 4; i++) {
                    // loop through transforms
                    if (i == 0) Buffer.append(buffer, template[0]);
                    else {
                        Buffer.append(buffer, template[1]);
                        Buffer.append(buffer, scales[i - 1]);
                        Buffer.append(buffer, template[2]);
                        if (i <= 2) Buffer.append(buffer, "-");
                        Buffer.append(buffer, i <= 2 ? value : "0");
                        Buffer.append(buffer, " ");
                        if (i >= 2) Buffer.append(buffer, "-");
                        Buffer.append(buffer, i >= 2 ? value : "0");
                        Buffer.append(buffer, template[3]);
                    }
                    // denote what quad the transformsshould be used for
                    Buffer.append(buffer, template[4]);
                    if (s > 0)
                        Buffer.append(buffer, Strings.toString(uint256(s + 1)));
                    Buffer.append(buffer, template[5]);
                }
            }
        }
        // add final scaling
        string memory scaleWhole = Strings.toString(uint256(scale).div(100));
        string memory scaleDecimals = Strings.toString(uint256(scale).mod(100));
        Buffer.append(buffer, template[6]);
        Buffer.append(buffer, template[1]);
        Buffer.append(buffer, scaleWhole);
        Buffer.append(buffer, ".");
        Buffer.append(buffer, scaleDecimals);
        Buffer.append(buffer, " ");
        Buffer.append(buffer, scaleWhole);
        Buffer.append(buffer, ".");
        Buffer.append(buffer, scaleDecimals);
        Buffer.append(buffer, template[3]);
        Buffer.append(buffer, template[4]);
        Buffer.append(buffer, "4");
        Buffer.append(buffer, template[5]);

        Buffer.append(buffer, "\n</svg>"); // add closing svg tag
        return Buffer.toString(buffer);
    }

    /**
     * @dev calculate the animation modulators for a shape
     * @param animation randomn numbers
     * @param frame of token to render
     * @return mod struct of modulator values
     */
    function _calculateMods(
        uint256 animation,
        uint256 frame,
        uint256 shape
    ) internal pure returns (Modulation memory mod) {
        // set animation modifiers to default
        mod = Modulation({
            color: 0,
            hatch: 0,
            stack: 0,
            spacing: [0, 0, 0, 0],
            sizeRange: [0, 0, 0, 0],
            position: [0, 0],
            size: [0, 0],
            mirror: [0, 0, 0]
        });
        // apply animation based on animation, frame and shape values
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
            mod.mirror[0] = uint8(frame);
        } else if (animation == 4) {
            // squash and squeze
            // transfer height to width and vice versa
            // TODO: change to an inverted ralationship once signed modulation is implemented
            mod.size[0] = uint8(frame + shape);
            mod.size[1] = uint8(frame + shape);
        }
    }

    /**
     * @dev render a token's art
     * @param _id of token
     * @param box TinyBox data structure
     * @param frame number to render
     * @return buffer of the SVG graphics markup of the token
     */
    function perpetualRenderer(
        uint256 _id,
        TinyBox memory box,
        uint256 frame
    ) public view returns (bytes memory buffer) {
        // initialize an empty buffer for the SVG markup
        buffer = new bytes(8192);

        // write the document header to the SVG buffer
        Buffer.append(buffer, header);

        // initilize RNG with the specified seed and blocks 0 through 1
        bytes32[] memory pool = Random.init(0, 1, box.randomness);

        // generate colors
        uint256[] memory colorValues = new uint256[](box.colors);
        for (uint256 i = 0; i < box.colors; i++)
            colorValues[i] = _generateColor(pool, _id);

        // generate an array of shapes
        uint256 shapeCount = box.shapes;
        Modulation memory mod;
        Shape[] memory shapes = new Shape[](box.shapes);
        for (uint256 i = 0; i < box.shapes; i++) {
            // calculate the animation modulators based on frames and animation id
            mod = _calculateMods(box.animation, frame, i);

            // modulate shape generator input parameters
            for (uint256 j = 0; j < 4; j++) {
                box.spacing[j] = uint16(
                    uint256(box.spacing[j]).add(mod.spacing[j])
                );
                box.size[j] = uint16(
                    uint256(box.size[j]).add(mod.sizeRange[j])
                );
            }
            // pick a random color from the generated colors list
            // modulate colors by colorShift
            uint256 color = colorValues[uint256(
                Random.uniform(pool, 0, int256(uint256(shapeCount).sub(1)))
            )
                .add(mod.color)
                .mod(shapeCount)];
            // offset hatching index start by hatch modulator
            bool hatching = (box.hatching > 0 &&
                i.add(mod.hatch).mod(box.hatching) == 0);
            // generate a shapes position and size using box parameters
            (
                int256[2] memory position,
                uint256[2] memory size
            ) = _generateShape(pool, box.spacing, box.size, hatching);
            // modulate the shape position and size
            position[0] = int256(uint256(position[0]).add(mod.position[0]));
            position[1] = int256(uint256(position[1]).add(mod.position[1]));
            size[0] = size[0].add(mod.size[0]);
            size[1] = size[1].add(mod.size[1]);
            // create a new shape and add it to the shapes list
            shapes[i] = Shape(position, size, color, 1000);
        }

        // add shapes to markup
        for (uint256 i = 0; i < box.shapes; i++) {
            Shape memory shape = shapes[i.add(mod.stack).mod(box.shapes)];
            // add a rectangle with given position, size and color to the SVG markup
            Buffer.rect(
                buffer,
                shape.position,
                shape.size,
                shape.color,
                shape.opacity
            );
        }

        // modulate mirroring and scaling transforms
        box.mirrorPositions[0] = int16(
            uint256(box.mirrorPositions[0]).add(mod.mirror[0])
        );
        box.mirrorPositions[1] = int16(
            uint256(box.mirrorPositions[1]).add(mod.mirror[1])
        );
        box.mirrorPositions[2] = int16(
            uint256(box.mirrorPositions[2]).add(mod.mirror[2])
        );

        // generate the footer with mirroring and scale transforms
        Buffer.append(
            buffer,
            _generateFooter(box.mirrors, box.mirrorPositions, box.scale)
        );

        // return the SVG markup buffer
        return buffer;
    }
}
