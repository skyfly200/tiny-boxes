//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.4;

import "./Decimal.sol";

struct Modulation {
    int256 color;
    int256 hatch;
    int256 stack;
    Decimal[3] mirror;
}

struct ShapeModulation {
    Decimal rotation;
    Decimal[2] origin;
    Decimal[2] offset;
    Decimal[2] scale;
    Decimal[2] skew;
    Decimal opacity;
    uint256 radius;
}
