// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;

struct TinyBox {
    uint128 randomness;
    uint16 hue;
    uint8 saturation;
    uint8 lightness;
    uint8 shapes;
    uint8 hatching;
    uint8 widthMin;
    uint8 widthMax;
    uint8 heightMin;
    uint8 heightMax;
    uint8 spread;
    uint8 grid;
    uint8 mirroring;
    uint8 bkg; // bkg shade/transparent setting default
    uint8 duration; // animation duration default
    uint8 options; // 8 boolean values packed - 0th is the animate flag
}
