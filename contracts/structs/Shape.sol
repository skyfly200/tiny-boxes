//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.4;

import "./Decimal.sol";

struct Shape {
    Decimal[2] position;
    Decimal[2] size;
    Decimal opacity;
    uint256 radius;
    uint256 color;
}