//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.4;

struct TinyBox {
    uint256 seed;
    uint256 randomness;
    uint8 animation;
    uint8 shapes;
    uint8 colors;
    uint16 hatching;
    uint16 scale;
    int16[3] mirrorPositions;
    uint16[4] size;
    uint16[4] spacing;
    bool[3] mirrors;
}
