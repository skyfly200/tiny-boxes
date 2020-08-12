//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.8;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.1.0/contracts/utils/Strings.sol";

import "./libraries/Utils.sol";
import "./libraries/FixidityLib.sol";
import "./libraries/SVGBuffer.sol";

contract Colors {
    using SVGBuffer for *;
    using Strings for uint256;
    using Utils for *;

    /**
     * @dev Contract constructor.
     */
    //constructor() public {}

    function fixedToString(int256 hue) internal view returns (string memory) {
        // empty buffer for the HSV string
        bytes memory buffer = new bytes(8192);

        uint8 printDecimals = 5;

        buffer.append(
            FixidityLib.fromFixed(FixidityLib.integer(hue)).toString()
        );
        buffer.append(".");
        buffer.append(
            FixidityLib
                .fromFixed(FixidityLib.fractional(hue), printDecimals)
                .toString()
        );

        return buffer.toString();
    }

    function generateHues(
        int256 base,
        uint8 decimals,
        uint8 scheme
    ) external pure returns (int256[] memory hues) {
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

        for (uint256 i = 0; i < 3; i++)
            hues[i] = FixidityLib.add(
                FixidityLib.newFixed(base, decimals),
                FixidityLib.newFixed(int256(schemes[scheme][i]))
            );
    }

    function generateHsvColor(
        int256 hue,
        uint8 sat,
        uint8 level
    ) external pure returns (int256[3] memory color) {
        // saturation levels
        uint8[4] memory saturations = [0, 50, 75, 100];

        // brightness levels
        uint8[9] memory levels = [0, 25, 40, 45, 50, 55, 60, 75, 100];

        // HSV color output
        color = [hue, saturations[sat], levels[level]];
    }
}
