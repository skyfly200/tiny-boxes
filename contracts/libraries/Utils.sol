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

    // special toString for signed 16 bit ints
    function toString(int16 val) public view returns (string memory) {
        bytes memory buffer = new bytes(8192);
        if (val >= 0) buffer.append(uint256(val).toString());
        else {
            buffer.append("-");
            buffer.append(uint256(int256(val).mul(-1)).toString());
        }
        return buffer.toString();
    }

    function toHexColor(
        uint256 rgb,
        bytes memory buffer
    ) internal pure {
        require(SVGBuffer.hasCapacityFor(buffer, 6), "Buffer.rect: no capacity for color");
        assembly {
            function hexrgb(x, v) -> y {
                let blo := and(v, 0xf)
                let bhi := and(shr(4, v), 0xf)
                let glo := and(shr(8, v), 0xf)
                let ghi := and(shr(12, v), 0xf)
                let rlo := and(shr(16, v), 0xf)
                let rhi := and(shr(20, v), 0xf)
                mstore8(x, add(add(rhi, mul(div(rhi, 10), 39)), 48))
                mstore8(add(x, 1), add(add(rlo, mul(div(rlo, 10), 39)), 48))
                mstore8(add(x, 2), add(add(ghi, mul(div(ghi, 10), 39)), 48))
                mstore8(add(x, 3), add(add(glo, mul(div(glo, 10), 39)), 48))
                mstore8(add(x, 4), add(add(bhi, mul(div(bhi, 10), 39)), 48))
                mstore8(add(x, 5), add(add(blo, mul(div(blo, 10), 39)), 48))
                y := add(x, 6)
            }
            let strIdx := add(mload(add(buffer, 32)), add(buffer, 64))
            strIdx := hexrgb(strIdx, rgb)
            mstore(add(buffer, 32), sub(sub(strIdx, buffer), 64))
        }
    }
}
