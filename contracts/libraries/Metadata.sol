//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.4;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../structs/Decimal.sol";
import "../structs/Shape.sol";
import "../structs/TinyBox.sol";
import "../structs/HSL.sol";

import "./Random.sol";
import "./Utils.sol";
import "./Decimal.sol";
import "./Colors.sol";
import "./StringUtilsLib.sol";
import "../structs/Decimal.sol";

library Metadata {
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

    /**
     * @dev render the header of the SVG markup
     * @return header string
     */
    function _generateColorMetadata(TinyBox memory box) internal pure returns (string memory) {
        string memory scheme = string(abi.encodePacked('<scheme>', uint256(box.colorPalette.scheme).toString(), '</scheme>'));
        string memory rootHue = string(abi.encodePacked('<rootHue>', uint256(box.colorPalette.hue).toString(), '</rootHue>'));
        string memory saturation = string(abi.encodePacked('<saturation>', uint256(box.colorPalette.saturation).toString(), '</saturation>'));
        string memory shades = string(abi.encodePacked('<shades>', uint256(box.colorPalette.shades).toString(), '</shades>'));
        string memory lightness = string(abi.encodePacked('<lightness>', uint256(box.colorPalette.lightnessRange[0]).toString(), '-', uint256(box.colorPalette.lightnessRange[0]).toString(), '</lightness>'));

        return string(abi.encodePacked(
            '<color>',
            scheme, rootHue, saturation, shades, lightness,
            '</color>'
        ));
    }
    
    /**
     * @dev render the header of the SVG markup
     * @return header string
     */
    function _generateShapesMetadata(TinyBox memory box) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<shapes>',
                '<count>', uint256(box.shapes).toString(), '</count>',
                '<hatching>', uint256(box.hatching).toString(), '</hatching>',
                '<width>', uint256(box.size[0]).toString(), '-', uint256(box.size[1]).toString(), '</width>',
                '<height>', uint256(box.size[2]).toString(), '-', uint256(box.size[3]).toString(), '</height>',
            '</shapes>'
        ));
    }
    
    /**
     * @dev render the header of the SVG markup
     * @return header string
     */
    function _generatePlacementMetadata(TinyBox memory box) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<placement>',
                '<rows>', uint256(box.spacing[0]).toString(), '</rows>',
                '<columns>', uint256(box.spacing[1]).toString(), '</columns>',
                '<spread>', uint256(box.spacing[2]).toString(), 'x ', uint256(box.spacing[3]).toString(), 'y</spread>',
            '</placement>'
        ));
    }
    
    /**
     * @dev render the header of the SVG markup
     * @return header string
     */
    function _generateMirrorMetadata(TinyBox memory box) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<mirror>',
                '<mirrorPositions>',
                    uint256(box.mirrorPositions[0]).toString(), ',',
                    uint256(box.mirrorPositions[1]).toString(), ',',
                    uint256(box.mirrorPositions[2]).toString(),
                '</mirrorPositions>',
                '<scale>',
                    uint256(box.scale).toString(),
                '</scale>',
            '</mirror>'
        ));
    }

    /**
     * @dev render the header of the SVG markup
     * @return header string
     */
    function _generateMetadata(TinyBox memory box, string memory slot) internal pure returns (string memory) {
        string memory colors = _generateColorMetadata(box);
        string memory shapes = _generateShapesMetadata(box);
        string memory placement = _generatePlacementMetadata(box);
        string memory mirror = _generateMirrorMetadata(box);

        string memory animation = string(abi.encodePacked('<animation>', uint256(box.animation).toString(), '</animation>'));

        return string(abi.encodePacked('<metadata>', animation, colors, shapes, placement, mirror, slot, '</metadata>'));
    }
}
