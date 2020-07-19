//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.4;

import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./SVGBuffer.sol";

library Utils {
    using SVGBuffer for bytes;
    using SignedSafeMath for int256;
    using Strings for uint256;

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

    // special toString for signed 8 bit ints
    function toString(int16 val) public view returns (string memory) {
        bytes memory buffer = new bytes(8192);
        if (val >= 0) buffer.append(uint256(val).toString());
        else {
            buffer.append("-");
            buffer.append(uint256(int256(val).mul(-1)).toString());
        }
        return buffer.toString();
    }
}
