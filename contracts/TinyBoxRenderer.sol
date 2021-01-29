// SPDX-License-Identifier: MIT
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
import "./libraries/Utils.sol";
import "./libraries/Animation.sol";
import "./libraries/Metadata.sol";
import "./libraries/Random.sol";
import "./libraries/Colors.sol";

//import "hardhat/console.sol";

contract TinyBoxRenderer {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using Random for bytes32[];
    using Metadata for TinyBox;
    using Animation for TinyBox;
    using Strings for *;
    using Colors for *;
    using SVG for *;
    using Utils for *;

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
        uint8[2] memory spacing,
        uint8[4] memory size,
        bool hatched
    )
        internal
        pure
        returns (int256[2] memory positions, int256[2] memory dimensions)
    {
        // PRNG for box position
        int256[2] memory grid = [
            int256(uint256(spacing[1]).mod(16)).add(1),
            int256(uint256(spacing[1]).div(16)).add(1)
        ];
        positions = [
            pool.uniform( -(int256(600).div(grid[0].add(1)).div(200).mul(int256(spacing[0]))), (int256(600).div(grid[0].add(1)).div(200).mul(int256(spacing[0])))).add(
            (int256(600).div(grid[0].add(1)).mul(pool.uniform(0, grid[0])))),
            pool.uniform( -(int256(600).div(grid[1].add(1)).div(200).mul(int256(spacing[0]))), (int256(600).div(grid[1].add(1)).div(200).mul(int256(spacing[0])))).add(
            (int256(600).div(grid[1].add(1)).mul(pool.uniform(0, grid[1]))))
        ];
        // PRNG for box size
        if (hatched) {
            int256 horizontal = pool.uniform(0, 1);
            int256 width = pool.uniform(25, 40).add(int256(500).mul(horizontal));
            dimensions = [
                width,
                pool.uniform(10, 25).add(int256(540).sub(width))
            ];
        } else
            dimensions = [
                pool.uniform(int256(size[0]), int256(size[1])),
                pool.uniform(int256(size[2]), int256(size[3]))
            ];
    }

    /**
     * @dev generate a shape
     * @param index of the shape
     * @param box data to make a shape from
     * @param dVals deterministicaly calculated values
     * @return positions of shape
     */
    function _generateShape(
        bytes32[] memory pool,
        uint256 index,
        TinyBox memory box,
        uint8[4] memory dVals
    )
        internal
        view
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
        ) = _generateBox(pool, [box.spread, box.grid], [box.widthMin,box.widthMax,box.heightMin,box.heightMax], hatching);
        // lookup a random color from the color palette
        uint8 hue = uint8(pool.uniform(0, 3));
        uint8 shade = uint8(pool.uniform(0, int256(dVals[2]).sub(1)));
        HSL memory color;
        if (dVals[1] == 10) {
            // seed the random scheme from the extra bit space of the rootHue
            bytes32[] memory huePool = Random.init(uint256(box.hue).div(360).add(hue));
            color = HSL(
                hue == 0 ? box.hue : uint16(huePool.uniform(0,359)),
                box.saturation,
                Colors.calcShade(box.lightness, dVals[2], dVals[3], shade)
            );
        } else {
            color = dVals[1].lookupColor(box.hue,box.saturation,box.lightness,dVals[2],dVals[3],shade,hue);
        }
        return Shape(position, size, color);
    }

    /**
     * @dev render the footer string for mirring effects
     * @param mirroring generator settings
     * @return footer string
     */
    function _generateMirroring(
        uint8 mirroring
    ) internal pure returns (string memory) {
        string[4] memory scales = ['1 1','-1 1','1 -1','-1 -1'];
        uint16[3] memory levels = [600, 1200, 2400];
        // reference shapes symbol at core of mirroring
        string memory symbols = string(abi.encodePacked('<symbol id="quad0">',SVG._g('', SVG._use('shapes','')),'</symbol>'));
        // loop through nested mirroring levels
        for (uint256 s = 0; s < 3; s++) {
            string memory id = string(abi.encodePacked('quad', s.toString()));
            string memory copies;
            // check this mirror levels mode
            string memory value = string(abi.encodePacked('-', uint256(levels[s]).toString()));
            // select mirriring type for this level
            uint8 m = uint8(uint256(mirroring).div(4**s).mod(4));
            bool[4] memory switches = [m != 2, m > 1, m > 1, m % 2 == 1];
            // generate mirrored copies
            for (uint8 i = 0; i < 4; i++) {
                if (switches[i]) {
                    string memory transform = string(abi.encodePacked(
                        'transform="scale(', scales[i], ') translate(', (i%2 == 1) ? value : '0', ' ', (i > 1) ? value : '0', ')"'
                    ));
                    copies = string(abi.encodePacked(copies,SVG._g(transform, SVG._use(id,''))));
                }
            }
            // wrap symbol and all copies in a new symbol
            symbols = string(abi.encodePacked('<symbol id="quad',(s+1).toString(),'">',symbols,copies,'</symbol>')); // wrap last level in a shape tag to refer to later
        }
        // add final scaling transform
        uint256 scale = uint256(mirroring).div(16) == 0 ? (uint256(mirroring).div(4) == 0 ? 4 : 2) : 1;
        string memory attrs = string(abi.encodePacked(
            'transform="scale(', scale.toString(), ' ', scale.toString(), ')" clip-path="url(#clip)"'
        ));
        string memory finalScale = SVG._g(attrs, SVG._use('quad3', ''));
        return string(abi.encodePacked(symbols,finalScale));
    }

    /**
     * @dev render TinyBox artwork
     * @param box TinyBox data structure
     * @param id of the token to render
     * @param owner of the token rendered
     * @param dVals deterministic vals for rendering
     * @param _slot string for embeding custom additions
     * @return markup of the SVG graphics of the token as a string
     */
    function perpetualRenderer(TinyBox memory box, uint256 id, address owner, uint8[4] memory dVals, string memory _slot)
        public
        view
        returns (string memory)
    {
        // seed PRNG
        bytes32[] memory pool = Random.init(box.randomness);

        // generate shapes (shapes + animations)
        string memory shapes = "";
        for (uint256 i = 0; i < uint256(box.shapes); i++) {
            Shape memory shape = _generateShape(pool, i, box, dVals);
            shapes = string(abi.encodePacked(shapes,
                SVG._rect(shape, (box.options%8 != 0) ?
                    box._generateAnimation(dVals[0],shape,i) : ''
                )
            ));
        }
        // wrap shapes in a symbol with the id "shapes"
        string memory defs = string(abi.encodePacked(
            _slot,
            '<defs><rect id="cover" width="100%" height="100%" fill="hsl(0,0%,0%,0%)" /><clipPath id="clip"><use xlink:href="#cover"/></clipPath><symbol id="shapes">',
            shapes,
            '</symbol></defs>'
        ));

        // build up the SVG markup
        return SVG._SVG(
            ((box.options/8)%2 == 1) ? "" : box.bkg._parseBkg(),
            string(abi.encodePacked(
                box._generateMetadata(dVals,id,owner),
                defs,
                _generateMirroring(box.mirroring),
                SVG._use('cover', 'target')
            ))
        );
    }
}
