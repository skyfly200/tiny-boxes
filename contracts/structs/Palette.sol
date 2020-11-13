//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.4;

struct Palette {
    uint16 hue;
    uint8 saturation;
    uint8[2] lightnessRange;
    uint8 scheme;
    uint8 shades;
}