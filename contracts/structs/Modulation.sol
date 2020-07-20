//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.4;

import "./Decimal.sol";

struct Modulation {
    int256 color;
    int256 hatch;
    int256 stack;
    uint8[4] spacing;
    uint8[4] sizeRange;
    Decimal[2] position;
    Decimal[2] size;
    Decimal[3] mirror;
    Decimal opacity;
    uint256 radius;
}