//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/SafeCast.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/SignedSafeMath.sol";

import "./Utils.sol";
import "./FixidityLib.sol";
import "./SVGBuffer.sol";

import "../structs/HSL.sol";
import "../structs/Palette.sol";

library Colors {
    using SVGBuffer for *;
    using Strings for *;
    using Utils for *;
    using SafeCast for *;
    using SafeMath for *;
    using SignedSafeMath for *;

    function toString(HSL calldata color) external pure returns (string memory) {
        return string(abi.encodePacked("hsl(", uint256(color.hue).toString(), ",", uint256(color.saturation).toString(), "%,", uint256(color.lightness).toString(), "%)"));
    }
    
    function lookupHue(
        uint16 base,
        uint8 scheme,
        uint8 index
    ) public pure returns (uint16 hue) {
        uint16[3][8] memory schemes = [
            [uint16(180), uint16(180), uint16(0)], // complimentary
            [uint16(30), uint16(330), uint16(0)], // analogous
            [uint16(150), uint16(210), uint16(0)], // split complimentary
            [uint16(120), uint16(240), uint16(0)], // triadic
            [uint16(150), uint16(180), uint16(210)], // complimentary and analogous
            [uint16(30), uint16(180), uint16(330)], // analogous and complimentary
            [uint16(90), uint16(180), uint16(270)], // square
            [uint16(60), uint16(180), uint16(240)] // tetradic
        ];

        require(scheme < schemes.length, "Invalid scheme id");
        require(index < 4, "Invalid color index");

        if (index == 0) hue = base;
        else hue = uint16(uint256(base).add(schemes[scheme][index-1]));
    }

    function lookupColor(
        Palette memory pal,
        uint8 color,
        uint8 shade
    ) public pure returns (HSL memory) {
        uint16 h = lookupHue(pal.hue, pal.scheme, color);
        uint8 s = pal.saturation;
        uint8 l;
        if (pal.shades > 0) {
            uint256 range = uint256(pal.lightnessRange[1]).sub(pal.lightnessRange[0]);
            uint256 step = range.div(uint256(pal.shades));
            uint256 offset = uint256(shade.mul(step));
            l = uint8(uint256(pal.lightnessRange[1]).sub(offset));
        } else {
            l = pal.lightnessRange[1];
        }
        return HSL(h, s, l);
    }

    function generateColors(Palette memory palette) public pure returns (HSL[] memory colors) {
        colors = new HSL[](4 * palette.shades + 1);
        for (uint8 h = 0; h < 4; h++)
            for (uint8 s = 0; s <= palette.shades; s++) 
                colors[h * palette.shades + s] = lookupColor(palette,h,s);
    }
}
