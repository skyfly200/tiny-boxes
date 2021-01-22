//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/SafeCast.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "./Utils.sol";

import "./Random.sol";

import "../structs/HSL.sol";
import "../structs/Palette.sol";

library Colors {
    using Strings for *;
    using SafeCast for *;
    using SafeMath for *;
    using Random for bytes32[];

    function toString(HSL calldata color) external pure returns (string memory) {
        return string(abi.encodePacked("hsl(", uint256(color.hue).toString(), ",", uint256(color.saturation).toString(), "%,", uint256(color.lightness).toString(), "%)"));
    }
    
    function lookupHue(
        uint16 rootHue,
        uint8 scheme,
        uint8 index
    ) public view returns (uint16 hue) {
        // seed the random scheme from the extra bit space of the rootHue
        uint256 colorSeed = rootHue.div(360);
        bytes32[] memory huePool = Random.init(colorSeed);
        uint16[3] memory randHues = [
            uint16(huePool.uniform(0,359)),
            uint16(uint256(huePool.uniform(10,369)).sub(10)),
            uint16(uint256(huePool.uniform(20,379)).sub(20))
        ];
        
        uint16[3][11] memory schemes = [
            [uint16(120), uint16(240), uint16(0)], // triadic
            [uint16(180), uint16(180), uint16(0)], // complimentary
            [uint16(60), uint16(180), uint16(240)], // tetradic
            [uint16(30), uint16(330), uint16(0)], // analogous
            [uint16(30), uint16(180), uint16(330)], // analogous and complimentary
            [uint16(150), uint16(210), uint16(0)], // split complimentary
            [uint16(150), uint16(180), uint16(210)], // complimentary and analogous
            [uint16(30), uint16(60), uint16(90)], // series
            [uint16(90), uint16(180), uint16(270)], // square
            [uint16(0), uint16(0), uint16(0)], // mono
            randHues // random
        ];

        require(scheme < schemes.length, "Invalid scheme id");
        require(index < 4, "Invalid color index");

        if (index == 0) hue = rootHue;
        else hue = uint16(rootHue.add(schemes[scheme][index-1]));
    }

    function lookupColor(
        Palette memory pal,
        uint8 hueIndex,
        uint8 shade
    ) public view returns (HSL memory) {
        uint16 h = lookupHue(pal.root.hue, pal.scheme, hueIndex);
        uint8 s = pal.root.saturation;
        uint8 l;
        if (pal.shades > 1) {
            uint256 range = uint256(pal.contrast);
            uint256 step = range.div(uint256(pal.shades));
            uint256 offset = uint256(shade.mul(step));
            l = uint8(uint256(pal.root.lightness).sub(offset));
        } else {
            l = pal.root.lightness;
        }
        return HSL(h, s, l);
    }

    /**
     * @dev parse the bkg value into an HSL color
     * @param bkg settings packed int 8 bits
     * @return HSL color style CSS string
     */
    function _parseBkg(uint8 bkg) internal pure returns (string memory) {
        uint256 hue = (bkg / 16) * 24;
        uint256 sat = hue == 0 ? 0 : ((bkg / 4) % 4) * 25;
        uint256 lit = hue == 0 ? (625 * (bkg % 16)) / 100 : ((bkg % 4) + 1) * 20;
        return string(abi.encodePacked("background-color:hsl(", hue.toString(), ",", sat.toString(), "%,", lit.toString(), "%);"));
    }
}
