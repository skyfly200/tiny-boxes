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

    function toString(address account) public pure returns(string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(uint256 value) public pure returns(string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes32 value) public pure returns(string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes memory data) public pure returns(string memory) {
        bytes memory alphabet = "0123456789ABCDEF";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

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
        string memory size = string(abi.encodePacked(
            '<width>', uint256(box.size[0]).toString(), '-', uint256(box.size[1]).toString(), '</width>',
            '<height>', uint256(box.size[2]).toString(), '-', uint256(box.size[3]).toString(), '</height>'
        ));
        return string(abi.encodePacked(
            '<shapes>',
                '<count>', uint256(box.shapes).toString(), '</count>',
                '<hatching>', uint256(box.hatching).toString(), '</hatching>',
                '<size>', size, '</size>',
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
    function _generateMetadata(TinyBox memory box, bool animate, int256 id, address owner) internal view returns (string memory) {
        string memory colors = _generateColorMetadata(box);
        string memory shapes = _generateShapesMetadata(box);
        string memory placement = _generatePlacementMetadata(box);
        string memory mirror = _generateMirrorMetadata(box);

        string memory animation = string(abi.encodePacked(
            '<animation>',
                '<animated>',
                    animate ? 'true' : 'false',
                '</animated>',
                '<id>',
                    uint256(box.animation).toString(),
                '</id>',
            '</animation>'
        ));

        string memory token = id >= 0 ? string(abi.encodePacked(
            '<token>',
                '<id>',
                    id.toString(),
                '</id>',
                '<owner>',
                    toString(owner),
                '</owner>',
            '</token>'
        )) : '';

        string memory contractAddress = string(abi.encodePacked(
            '<contract>',
                toString(address(this)),
            '</contract>'
        ));

        string memory renderedAt = string(abi.encodePacked('<renderedAt>',now.toString(),'</renderedAt>')); // TODO: add timestamp here

        return string(abi.encodePacked('<metadata>', contractAddress, renderedAt, token, animation, colors, shapes, placement, mirror, '</metadata>'));
    }
}
