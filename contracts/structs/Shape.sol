//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.4;

import "./Decimal.sol";

struct Shape {
    int256[2] position;
    int256[2] size;
    Decimal opacity;
    Decimal rotation;
    Decimal[2] origin;
    Decimal[2] offset;
    Decimal[2] skew;
    Decimal[2] scale;
    uint256 radius;
    uint256 color;
}
