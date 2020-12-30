//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./structs/Decimal.sol";
import "./structs/Shape.sol";
import "./structs/TinyBox.sol";
import "./structs/HSL.sol";

import "./libraries/SVG.sol";
import "./libraries/Animation.sol";
import "./libraries/Metadata.sol";
import "./libraries/Random.sol";
import "./libraries/Decimal.sol";

library TinyBoxesRenderer {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using Random for bytes32[];
    using Metadata for TinyBox;
    using DecimalUtils for *;
    using Strings for *;

    uint8 public constant ANIMATION_COUNT = 24;

    /**
     * @dev generate a shape
     * @param pool randomn numbers pool
     * @param spacing for shapes
     * @param size of shapes
     * @param hatched mode bool switch
     * @return positions of shape
     */
    function _generateBox(
        bytes32[] memory pool,
        uint8[4] memory spacing,
        uint8[4] memory size,
        bool hatched
    )
        internal
        pure
        returns (int256[2] memory positions, int256[2] memory dimensions)
    {
        // PRNG for box position
        positions = [
            pool.uniform(-(int256(spacing[0])), int256(spacing[0])) +
                ((pool.uniform(0, int256(spacing[2]).sub(1)).mul(800)).div(
                    int256(spacing[2]))),
            pool.uniform(-(int256(spacing[1])), int256(spacing[1])) +
                ((pool.uniform(0, int256(spacing[3]).sub(1)).mul(800)).div(
                    int256(spacing[3])))
        ];
        // PRNG for box size
        if (hatched) {
            int256 horizontal = pool.uniform(0, 1);
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
     * @return positions of shape
     */
    function _generateShape(
        bytes32[] memory pool,
        uint256 index,
        TinyBox memory box,
        uint8 scheme
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
        // lookup a random color from the color palette
        uint8 hue = uint8(pool.uniform(0, 3));
        uint8 shade = uint8(pool.uniform(0, box.shades));
        HSL memory color = Colors.lookupColor(Palette(box.color, box.contrast, box.shades, scheme),hue,shade);
        return Shape(position, size, color);
    }

    /**
     * @dev render the footer string for mirring effects
     * @param mirroring generator settings
     * @return footer string
     */
    function _generateMirroring(
        uint8[4] memory mirroring
    ) internal pure returns (string memory) {
        string[3] memory scales = ['-1 1', '1 -1', '-1 -1'];
        // reference shapes symbol at core of mirroring
        string memory symbols = string(abi.encodePacked('<symbol id="quad0">',SVG._g(SVG._use('shapes')),'</symbol>'));
        // loop through nested mirroring levels
        for (uint256 s = 0; s < 3; s++) {
            string memory id = string(abi.encodePacked('quad', s.toString()));
            // generate unmirrored copy
            string memory copies = SVG._g(SVG._use(id));
            // check if this mirror level is active
            if (mirroring[s] > 0) {
                string memory value = string(abi.encodePacked('-', uint256(mirroring[s]).mul(10).toString()));
                // generate mirrored copies
                for (uint8 i = 0; i < 3; i++) {
                    string memory transform = string(abi.encodePacked(
                        'scale(', scales[i], ') translate(', (i != 1) ? value : '0', ' ', (i > 0) ? value : '0', ')'
                    ));
                    copies = string(abi.encodePacked(copies,SVG._g(transform, SVG._use(id))));
                }
            }
            // wrap symbol and all copies in a new symbol
            symbols = string(abi.encodePacked('<symbol id="quad',(s+1).toString(),'">',symbols,copies,'</symbol>')); // wrap last level in a shape tag to refer to later
        }
        // add final scaling transform
        Decimal memory scale = int256(mirroring[3]).toDecimal(1);
        string memory transform = string(abi.encodePacked(
            'scale(', scale.toString(), ' ', scale.toString(), ')'
        ));
        string memory finalScale = SVG._g(transform, SVG._use('quad3'));
        return string(abi.encodePacked(symbols,finalScale));
    }

    /**
     * @dev render a token's art
     * @param box TinyBox data structure
     * @param animate boolean flag to enable/disable animation
     * @param id of the token rendered
     * @param owner of the token rendered
     * @return markup of the SVG graphics of the token as a string
     */
    function perpetualRenderer(TinyBox memory box, uint256 randomness, bool animate, uint256 id, address owner)
        public
        view
        returns (string memory)
    {
        // --- Calculate Generative Shape Data ---

        // seed PRNG
        bytes32[] memory pool = Random.init(randomness);

        // calculate deteministicaly random values
        uint8[2] memory rngVals = [
            uint8(randomness.mod(ANIMATION_COUNT)), // animation
            uint8(id.div(1000)) // scheme
        ];

        // --- Render SVG Markup ---

        // generate the metadata
        string memory metadata = box._generateMetadata(rngVals[0],animate,id,owner,rngVals[1]);

        // generate shapes (shapes + animations)
        string memory shapes = "";
        for (uint256 i = 0; i < uint256(box.shapes); i++) {
            Shape memory shape = _generateShape(pool, i, box, rngVals[1]);
            shapes = string(abi.encodePacked(shapes, 
                animate ? SVG._rect(shape, Animation._generateAnimation(box,rngVals[0],shape,i)) : SVG._rect(shape)
            ));
        }
        // wrap shapes in a symbol with the id "shapes"
        string memory defs = string(abi.encodePacked('<defs><symbol id="shapes">', shapes, '</symbol></defs>'));

        // generate the footer
        string memory mirroring = _generateMirroring(box.mirroring);

        string memory svg = SVG._SVG(string(abi.encodePacked(metadata, defs, mirroring)));

        return svg;
    }
}
