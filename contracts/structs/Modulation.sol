//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.4;

struct Modulation {
    int256 color;
    int256 hatch;
    int256 stack;
    uint256 opacity;
    uint8[4] spacing;
    uint8[4] sizeRange;
    int8[2] position;
    int8[2] size;
    int8[3] mirror;
}