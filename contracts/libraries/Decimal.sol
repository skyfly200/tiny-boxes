// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/SafeCast.sol";

import "./Utils.sol";
import "./FixidityLib.sol";
import "../structs/Decimal.sol";

library DecimalUtils {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using Strings for *;
    using Utils for *;
    using SafeCast for *;
    
    // convert a Decimal to a string
    function toString(Decimal memory number) internal pure returns (string memory out) {
        int256 whole = FixidityLib.fromFixed(number.value);
        int256 fraction = FixidityLib.fromFixed(FixidityLib.fractional(FixidityLib.abs(number.value)), number.decimals);
        if (whole > 0) out = string(abi.encodePacked(whole.toString()));
        if (fraction > 0) out = string(abi.encodePacked( out, ".", ( number.decimals > 0 ? fraction.zeroPad(number.decimals) : fraction.toString() ) ));
    }

    // create a new Decimal
    function toDecimal(int256 value, uint8 decimals, uint8 significant) internal pure returns (Decimal memory result) {
        // scale value and return a new decimal
        return Decimal(FixidityLib.newFixed(value, decimals), significant);
    }

    // create a new Decimal
    function toDecimal(int256 value, uint8 decimals) internal pure returns (Decimal memory result) {
        // scale value and return a new decimal
        return Decimal(FixidityLib.newFixed(value, decimals), decimals);
    }

    // create a new Decimal
    function toDecimal(int256 value) internal pure returns (Decimal memory result) {
        // scale value and return a new decimal
        return Decimal(FixidityLib.newFixed(value), 0);
    }
}
