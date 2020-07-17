//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.4;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../libraries/SVGBuffer.sol";
import "../structs/Decimal.sol";

library DecimalUtils {
    using SafeMath for uint256;
    //using SignedSafeMath for int256;
    using SVGBuffer for bytes;
    using Strings for *;

    // compute decimal parts
    function decimalParts(Decimal memory number) internal pure returns (uint256, uint256) {
        return (
            uint256(number.value).div(number.decimals),
            uint256(number.value).mod(number.decimals)
        );
    }

    // convert a Decimal to a string
    function toString(Decimal memory number) internal view returns (string memory) {
        ( uint256 wholeComponent, uint256 decimalComponent ) = decimalParts(number);
        bytes memory buffer = new bytes(8192);
        buffer.append(wholeComponent.toString());
        buffer.append(decimalComponent.toString());
        return buffer.toString();
    }
}
