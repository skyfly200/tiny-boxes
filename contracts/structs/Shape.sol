// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;

import "./Decimal.sol";
import "./HSL.sol";

struct Shape {
    int256[2] position;
    int256[2] size;
    HSL color;
}
