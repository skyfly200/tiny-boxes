//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/SafeCast.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "./Utils.sol";
import "./FixidityLib.sol";
import "./SVGBuffer.sol";

import "../structs/HSL.sol";

library Colors {
    using SVGBuffer for *;
    using Strings for *;
    using Utils for *;
    using SafeCast for *;
    using SafeMath for *;

    /**
     * @dev Contract constructor.
     */
    //constructor() public {}

    function toString(HSL calldata color) external view returns (string memory) {
        // new empty buffer for the HSL string
        bytes memory buffer = new bytes(8192);
        buffer.append("hsl(");
        buffer.append(uint256(color.hue).toString());
        buffer.append(",");
        buffer.append(uint256(color.saturation).toString());
        buffer.append("%,");
        buffer.append(uint256(color.lightness).toString());
        buffer.append("%)");
        return buffer.toString();
    }

    function generateHues(
        uint16 base,
        uint8 decimals,
        uint8 scheme
    ) public pure returns (uint16[4] memory hues) {
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

        require(scheme < schemes.length, "Invalid theme id");

        hues[0] = base;

        for (uint256 i = 0; i < 3; i++)
            hues[i + 1] = uint16(base.add(schemes[scheme][i]));
    }

    function testSchemes() external pure returns (HSL memory colors) {
        return generateScheme(3000, 100, 50, 0, 0)[0];
    }

    function generateScheme(
        uint16 rootHue,
        uint8 saturation,
        uint8 lightness,
        uint8 scheme,
        uint8 shades
    ) public pure returns (HSL[] memory colors) {
        uint16[4] memory hues = generateHues(rootHue, 2, scheme);
        uint8 s = saturation;
        uint8 l = lightness;

        for (uint256 i = 0; i < 4; i++) {
            uint16 h = hues[i];
            colors[i] = HSL(h, s, l);
            for (uint16 j = 0; j < shades; j++) {
                uint offset = j + 1 * 5;
                colors[4 + (i * j * 2) + j] = HSL(h, s, uint8(l.add(-offset)));
                colors[5 + (i * j * 2) + j] = HSL(h, s, uint8(l.add(offset)));
            }
        }
    }
}
