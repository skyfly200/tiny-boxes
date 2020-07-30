//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.4;

import "./Decimal.sol";

struct Modulation {
    int256 color;
    int256 hatch;
    int256 stack;
    uint8[4] spacing;
    uint8[4] sizeRange;
    Decimal rotation;
    Decimal[2] origin;
    Decimal[2] offset;
    Decimal[2] scale;
    Decimal[2] skew;
    Decimal[3] mirror;
    Decimal opacity;
    uint256 radius;
}
