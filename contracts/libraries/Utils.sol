//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.4;

import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./FixidityLib.sol";

library Utils {
    using SignedSafeMath for int256;
    using Strings for *;

    function stringToUint(string memory s)
        internal
        pure
        returns (uint256 result)
    {
        bytes memory b = bytes(s);
        uint256 i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }

    // special toString for signed ints
    function toString(int256 val) public pure returns (string memory out) {
        out = string(abi.encodePacked(
            (val < 0) ? "-" : "",
            uint256(val < 0 ? val.mul(-1) : val).toString()
        ));
    }
}
