//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.4;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../libraries/SVGBuffer.sol";
import "../structs/Decimal.sol";

library DecimalUtils {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using SVGBuffer for bytes;
    using Strings for *;

    // compute decimal parts
    function decimalParts(Decimal memory number) internal pure returns (int256, uint256) {
        return (
            int256(number.value).div(int256(10) ** number.decimals),
            uint256(number.value).mod(uint256(10) ** number.decimals)
        );
    }

    // convert a Decimal to a string
    // TODO: fix overflow error
    function toString(Decimal memory number) internal view returns (string memory) {
        ( int256 wholeComponent, uint256 decimalComponent ) = decimalParts(number);
        bytes memory buffer = new bytes(20);
        if (wholeComponent < 0) {
            buffer.append("-");
            buffer.append(uint256(wholeComponent.mul(-1)).toString());
        } else {
            buffer.append(uint256(wholeComponent).toString());
        }
        buffer.append(".");
        buffer.append(decimalComponent.toString());
        return buffer.toString();
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
}
