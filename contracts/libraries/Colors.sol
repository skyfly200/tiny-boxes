//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/SafeCast.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "./Utils.sol";

import "../structs/HSL.sol";
import "../structs/Palette.sol";

library Colors {
    using Strings for *;
    using SafeCast for *;
    using SafeMath for *;

    function toString(HSL calldata color) external pure returns (string memory) {
        return string(abi.encodePacked("hsl(", uint256(color.hue).toString(), ",", uint256(color.saturation).toString(), "%,", uint256(color.lightness).toString(), "%)"));
    }
    
    function lookupHue(
        uint16 rootHue,
        uint8 scheme,
        uint8 index
    ) public pure returns (uint16 hue) {
        uint16[3][10] memory schemes = [
            [uint16(120), uint16(240), uint16(0)], // triadic
            [uint16(180), uint16(180), uint16(0)], // complimentary
            [uint16(60), uint16(180), uint16(240)], // tetradic
            [uint16(30), uint16(330), uint16(0)], // analogous
            [uint16(30), uint16(180), uint16(330)], // analogous and complimentary
            [uint16(150), uint16(210), uint16(0)], // split complimentary
            [uint16(150), uint16(180), uint16(210)], // complimentary and analogous
            [uint16(30), uint16(60), uint16(90)], // series
            [uint16(90), uint16(180), uint16(270)], // square
            [uint16(0), uint16(0), uint16(0)] // mono
        ];

        require(scheme < schemes.length, "Invalid scheme id");
        require(index < 4, "Invalid color index");

        if (index == 0) hue = rootHue;
        else hue = uint16(uint256(rootHue).add(schemes[scheme][index-1]));
    }

    function lookupColor(
        Palette memory pal,
        uint8 hueIndex,
        uint8 shade
    ) public pure returns (HSL memory) {
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
}
