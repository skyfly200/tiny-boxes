//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.4;

import './Palette.sol';

struct TinyBox {
    uint256 randomness;
    uint8 animation;
    uint8 shapes;
    Palette colorPalette;
    uint16 hatching;
    uint16 scale;
    int16[3] mirrorPositions;
    uint16[4] size;
    uint16[4] spacing;
}
