//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.4;

import "@openzeppelin/contracts/utils/Strings.sol";

import "../structs/Decimal.sol";
import "../structs/Shape.sol";

import "./Utils.sol";
import "./Decimal.sol";
import "./Colors.sol";

library SVG {
    using DecimalUtils for *;
    using Utils for *;
    using Colors for *;
    using Strings for *;

    /**
     * @dev render a rectangle SVG tag with nested content
     * @param shape object
     * @param slot for nested tags (animations)
     */
    function _rect(Shape memory shape, string memory slot) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<rect x="',
            shape.position[0].toString(),
            '" y="',
            shape.position[1].toString(),
            '" width="',
            shape.size[0].toString(),
            '" height="',
            shape.size[1].toString(),
            '" transform-origin="600 600" style="fill:',
            shape.color.toString(),
            bytes(slot).length == 0 ?
                '"/>' :
                string(abi.encodePacked('">',slot,'</rect>'))
        ));
    }
    
    /**
     * @dev render a rectangle SVG tag
     * @param shape object
     */
    function _rect(Shape memory shape) internal pure returns (string memory) {
        return _rect(shape, '');
    }

    /**
     * @dev render an g(group) SVG tag with a transform
     * @param transformValues string, with SVG transform function
     * @param slot for nested group content
     */
    function _g(string memory transformValues, string memory slot) internal pure returns (string memory) {
        return string(abi.encodePacked('<g', 
        bytes(transformValues).length == 0 ? '' : string(abi.encodePacked(' transform="', transformValues, '"')),
        '>', slot,'</g>'));
    }

    /**
     * @dev render a g(group) SVG tag
     * @param slot for nested group content
     */
    function _g(string memory slot) internal pure returns (string memory) {
        return _g('', slot);
    }

    /**
     * @dev render a use SVG tag
     * @param id of the SVG tag to reference
     */
    function _use(string memory id) internal pure returns (string memory) {
        return string(abi.encodePacked('<use xlink:href="#', id,'"/>'));
    }
    
    /**
     * @dev render the outer SVG markup. XML version, doctype and SVG tag
     * @param body of the SVG markup
     * @return header string
     */
    function _generateSVG(string memory body) internal pure returns (string memory) {
        string memory xmlVersion = '<?xml version="1.0" encoding="UTF-8"?>';
        string memory doctype = '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">';
        string memory openingSVGTag = '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="100%" height="100%" viewBox="0 0 2400 2400" style="stroke-width:0;background-color:#121212">';

        return string(abi.encodePacked(xmlVersion, doctype, openingSVGTag, body, '</svg>'));
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
        string memory symbols = string(abi.encodePacked('<symbol id="quad0">',_g(_use('shapes')),'</symbol>'));
        // loop through nested mirroring levels
        for (uint256 s = 0; s < 3; s++) {
            string memory id = string(abi.encodePacked('quad', s.toString()));
            // generate unmirrored copy
            string memory copies = _g(_use(id));
            // check if this mirror level is active
            if (mirroring[s] > 0) {
                string memory value = string(abi.encodePacked('-', uint256(mirroring[s]).toString()));
                // generate mirrored copies
                for (uint8 i = 0; i < 3; i++) {
                    string memory transform = string(abi.encodePacked(
                        'scale(', scales[i], ') translate(', (i != 1) ? value : '0', ' ', (i > 0) ? value : '0', ')'
                    ));
                    copies = string(abi.encodePacked(copies,_g(transform, _use(id))));
                }
            }
            // wrap symbol and all copies in a new symbol
            symbols = string(abi.encodePacked('<symbol id="quad',(s+1).toString(),'">',symbols,copies,'</symbol>')); // wrap last level in a shape tag to refer to later
        }
        // add final scaling transform
        Decimal memory scale = int256(mirroring[3]).toDecimal(2);
        string memory transform = string(abi.encodePacked(
            'scale(', scale.toString(), ' ', scale.toString(), ')'
        ));
        string memory finalScale = _g(transform, _use('quad3'));
        return string(abi.encodePacked(symbols,finalScale));
    }
}
