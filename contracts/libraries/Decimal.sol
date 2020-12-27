//SPDX-License-Identifier: Unlicensed

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
        int256 fraction = FixidityLib.fractional(FixidityLib.abs(number.value));
        if (whole > 0) out = string(abi.encodePacked(whole.toString()));
        if (fraction > 0) out = string(abi.encodePacked( out, ".", fraction.toString() ));
    }

    // convert a Decimal to a string with zero padding
    function toString(Decimal memory number, uint256 places) internal pure returns (string memory out) {
        int256 whole = FixidityLib.fromFixed(number.value);
        int256 fraction = FixidityLib.fractional(FixidityLib.abs(number.value));
        if (whole > 0) out = string(abi.encodePacked(whole.toString()));
        if (fraction > 0) out = string(abi.encodePacked( out, ".", zeroPad(fraction, places) ));
    }

    function zeroPad(int256 value, uint256 places) internal pure returns (string memory out) {
        out = value.toString();
        for (uint i=(places-1); i>0; i--)
            if (value < int256(10**i))
                out = string(abi.encodePacked("0", out));
    }

    // add two decimals
    function add(Decimal memory a, Decimal memory b) internal pure returns (Decimal memory result) {
        // decide the order to add by decimal length
        (Decimal memory x, Decimal memory y) = a.decimals > b.decimals ? (a, b) : (b, a);
        // scale less precise value to match larger decimals
        int256 scaled = y.value.mul(int256(10)**(x.decimals - y.decimals));
        // add scaled values and return a new decimal
        return Decimal(scaled.add(x.value), x.decimals);
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
