//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.4;

import "./Decimal.sol";

struct Shape {
    int256[2] position;
    int256[2] size;
    uint256 color;
}
