//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.4;

import './HSL.sol';

struct TinyBox {
    uint8 shapes;
    uint8 hatching;
    uint8[4] mirroring;
    uint8[4] size;
    uint8[2] spacing;
    HSL color;
    uint8 contrast;
    uint8 shades;
}
