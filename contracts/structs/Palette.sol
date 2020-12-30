//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.4;

import './HSL.sol';

struct Palette {
    HSL root;
    uint8 contrast;
    uint8 shades;
    uint8 scheme;
}