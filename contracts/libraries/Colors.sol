//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;

import "@openzeppelin/contracts/utils/Strings.sol";

import "./Utils.sol";
import "./FixidityLib.sol";
import "./SVGBuffer.sol";

struct HSV {
    int256 hue;
    int256 saturation;
    int256 value;
}

contract Colors {
    using SVGBuffer for *;
    using Strings for uint256;
    using Utils for *;

    /**
     * @dev Contract constructor.
     */
    //constructor() public {}

    function toString(int256 value, uint8 decimals)
        external
        view
        returns (string memory)
    {
        // new empty buffer for the fixed point value as a string
        bytes memory buffer = new bytes(8192);
        buffer.append(
            FixidityLib.fromFixed(FixidityLib.integer(value)).toString()
        );
        buffer.append(".");
        buffer.append(
            FixidityLib
                .fromFixed(FixidityLib.fractional(value), decimals)
                .toString()
        );
        return buffer.toString();
    }

    function toString(HSV memory color) external view returns (string memory) {
        // new empty buffer for the HSV string
        bytes memory buffer = new bytes(8192);
        buffer.append("hsv(");
        buffer.append(toString(color.hue));
        buffer.append(",");
        buffer.append(toString(color.saturation));
        buffer.append(",");
        buffer.append(toString(color.value));
        buffer.append(")");
        return buffer.toString();
    }

    function generateHues(
        int256 base,
        uint8 decimals,
        uint8 scheme
    ) public pure returns (int256[4] memory hues) {
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

        hues[0] = FixidityLib.newFixed(base, decimals);

        for (uint256 i = 0; i < 3; i++)
            hues[i + 1] = FixidityLib.add(
                FixidityLib.newFixed(base, decimals),
                FixidityLib.newFixed(int256(schemes[scheme][i]))
            );
    }

    function testSchemes() external pure returns (HSV memory colors) {
        return generateScheme(3000, 100, 50, 0, 0)[0];
    }

    function generateScheme(
        int256 rootHue,
        int256 saturation,
        int256 value,
        uint8 scheme,
        uint8 shades
    ) public pure returns (HSV[] memory colors) {
        int256[4] memory hues = generateHues(rootHue, 2, scheme);
        int256 s = FixidityLib.newFixed(saturation);
        int256 v = FixidityLib.newFixed(value);

        for (uint256 i = 0; i < 4; i++) {
            int256 h = hues[i];
            colors[i] = HSV(h, s, v);
            for (uint256 j = 0; j < shades; j++) {
                int256 offset = FixidityLib.newFixed(int256(j + 1 * 5));
                colors[4 + (i * j * 2) + j] = HSV(
                    h,
                    s,
                    FixidityLib.add(v, -offset)
                );
                colors[5 + (i * j * 2) + j] = HSV(
                    h,
                    s,
                    FixidityLib.add(v, offset)
                );
            }
        }
    }
}
