// Sources flattened with hardhat v2.0.8 https://hardhat.org

// File @openzeppelin/contracts/math/SafeMath.sol@v3.1.0

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


// File @openzeppelin/contracts/math/SignedSafeMath.sol@v3.1.0



pragma solidity ^0.6.0;

/**
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error.
 */
library SignedSafeMath {
    int256 constant private _INT256_MIN = -2**255;

        /**
     * @dev Returns the multiplication of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two signed integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    /**
     * @dev Returns the subtraction of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    /**
     * @dev Returns the addition of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}


// File @openzeppelin/contracts/utils/Strings.sol@v3.1.0



pragma solidity ^0.6.0;

/**
 * @dev String operations.
 */
library Strings {
    /**
     * @dev Converts a `uint256` to its ASCII `string` representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}


// File contracts/structs/Decimal.sol


pragma solidity ^0.6.4;

struct Decimal {
    int256 value;
    uint8 decimals;
}


// File contracts/structs/HSL.sol


pragma solidity ^0.6.4;

struct HSL {
    uint16 hue;
    uint8 saturation;
    uint8 lightness;
}


// File contracts/structs/Shape.sol


pragma solidity ^0.6.4;
struct Shape {
    int256[2] position;
    int256[2] size;
    HSL color;
}


// File contracts/structs/TinyBox.sol


pragma solidity ^0.6.4;

struct TinyBox {
    uint128 randomness;
    uint16 hue;
    uint8 saturation;
    uint8 lightness;
    uint8 shapes;
    uint8 hatching;
    uint8 widthMin;
    uint8 widthMax;
    uint8 heightMin;
    uint8 heightMax;
    uint8 spread;
    uint8 grid;
    uint8 mirroring;
    uint8 bkg; // bkg shade/transparent setting default
    uint8 duration; // animation duration default
    uint8 options; // 8 boolean values packed - 0th is the animate flag
}


// File contracts/libraries/FixidityLib.sol


pragma solidity ^0.6.8;

/**
 * @title FixidityLib
 * @author Gadi Guy, Alberto Cuesta Canada
 * @notice This library provides fixed point arithmetic with protection against
 * overflow. 
 * All operations are done with int256 and the operands must have been created 
 * with any of the newFrom* functions, which shift the comma digits() to the 
 * right and check for limits.
 * When using this library be sure of using maxNewFixed() as the upper limit for
 * creation of fixed point numbers. Use maxFixedMul(), maxFixedDiv() and
 * maxFixedAdd() if you want to be certain that those operations don't 
 * overflow.
 */
    library FixidityLib {

    /**
     * @notice Number of positions that the comma is shifted to the right.
     */
    function digits() public pure returns(uint8) {
        return 24;
    }
    
    /**
     * @notice This is 1 in the fixed point units used in this library.
     * @dev Test fixed1() equals 10^digits()
     * Hardcoded to 24 digits.
     */
    function fixed1() public pure returns(int256) {
        return 1000000000000000000000000;
    }

    /**
     * @notice The amount of decimals lost on each multiplication operand.
     * @dev Test mulPrecision() equals sqrt(fixed1)
     * Hardcoded to 24 digits.
     */
    function mulPrecision() public pure returns(int256) {
        return 1000000000000;
    }

    /**
     * @notice Maximum value that can be represented in an int256
     * @dev Test maxInt256() equals 2^255 -1
     */
    function maxInt256() public pure returns(int256) {
        return 57896044618658097711785492504343953926634992332820282019728792003956564819967;
    }

    /**
     * @notice Minimum value that can be represented in an int256
     * @dev Test minInt256 equals (2^255) * (-1)
     */
    function minInt256() public pure returns(int256) {
        return -57896044618658097711785492504343953926634992332820282019728792003956564819968;
    }

    /**
     * @notice Maximum value that can be converted to fixed point. Optimize for
     * @dev deployment. 
     * Test maxNewFixed() equals maxInt256() / fixed1()
     * Hardcoded to 24 digits.
     */
    function maxNewFixed() public pure returns(int256) {
        return 57896044618658097711785492504343953926634992332820282;
    }

    /**
     * @notice Maximum value that can be converted to fixed point. Optimize for
     * deployment. 
     * @dev Test minNewFixed() equals -(maxInt256()) / fixed1()
     * Hardcoded to 24 digits.
     */
    function minNewFixed() public pure returns(int256) {
        return -57896044618658097711785492504343953926634992332820282;
    }

    /**
     * @notice Maximum value that can be safely used as an addition operator.
     * @dev Test maxFixedAdd() equals maxInt256()-1 / 2
     * Test add(maxFixedAdd(),maxFixedAdd()) equals maxFixedAdd() + maxFixedAdd()
     * Test add(maxFixedAdd()+1,maxFixedAdd()) throws 
     * Test add(-maxFixedAdd(),-maxFixedAdd()) equals -maxFixedAdd() - maxFixedAdd()
     * Test add(-maxFixedAdd(),-maxFixedAdd()-1) throws 
     */
    function maxFixedAdd() public pure returns(int256) {
        return 28948022309329048855892746252171976963317496166410141009864396001978282409983;
    }

    /**
     * @notice Maximum negative value that can be safely in a subtraction.
     * @dev Test maxFixedSub() equals minInt256() / 2
     */
    function maxFixedSub() public pure returns(int256) {
        return -28948022309329048855892746252171976963317496166410141009864396001978282409984;
    }

    /**
     * @notice Maximum value that can be safely used as a multiplication operator.
     * @dev Calculated as sqrt(maxInt256()*fixed1()). 
     * Be careful with your sqrt() implementation. I couldn't find a calculator
     * that would give the exact square root of maxInt256*fixed1 so this number
     * is below the real number by no more than 3*10**28. It is safe to use as
     * a limit for your multiplications, although powers of two of numbers over
     * this value might still work.
     * Test multiply(maxFixedMul(),maxFixedMul()) equals maxFixedMul() * maxFixedMul()
     * Test multiply(maxFixedMul(),maxFixedMul()+1) throws 
     * Test multiply(-maxFixedMul(),maxFixedMul()) equals -maxFixedMul() * maxFixedMul()
     * Test multiply(-maxFixedMul(),maxFixedMul()+1) throws 
     * Hardcoded to 24 digits.
     */
    function maxFixedMul() public pure returns(int256) {
        return 240615969168004498257251713877715648331380787511296;
    }

    /**
     * @notice Maximum value that can be safely used as a dividend.
     * @dev divide(maxFixedDiv,newFixedFraction(1,fixed1())) = maxInt256().
     * Test maxFixedDiv() equals maxInt256()/fixed1()
     * Test divide(maxFixedDiv(),multiply(mulPrecision(),mulPrecision())) = maxFixedDiv()*(10^digits())
     * Test divide(maxFixedDiv()+1,multiply(mulPrecision(),mulPrecision())) throws
     * Hardcoded to 24 digits.
     */
    function maxFixedDiv() public pure returns(int256) {
        return 57896044618658097711785492504343953926634992332820282;
    }

    /**
     * @notice Maximum value that can be safely used as a divisor.
     * @dev Test maxFixedDivisor() equals fixed1()*fixed1() - Or 10**(digits()*2)
     * Test divide(10**(digits()*2 + 1),10**(digits()*2)) = returns 10*fixed1()
     * Test divide(10**(digits()*2 + 1),10**(digits()*2 + 1)) = throws
     * Hardcoded to 24 digits.
     */
    function maxFixedDivisor() public pure returns(int256) {
        return 1000000000000000000000000000000000000000000000000;
    }

    /**
     * @notice Converts an int256 to fixed point units, equivalent to multiplying
     * by 10^digits().
     * @dev Test newFixed(0) returns 0
     * Test newFixed(1) returns fixed1()
     * Test newFixed(maxNewFixed()) returns maxNewFixed() * fixed1()
     * Test newFixed(maxNewFixed()+1) fails
     */
    function newFixed(int256 x)
        public
        pure
        returns (int256)
    {
        assert(x <= maxNewFixed());
        assert(x >= minNewFixed());
        return x * fixed1();
    }

    /**
     * @notice Converts an int256 in the fixed point representation of this 
     * library to a non decimal. All decimal digits will be truncated.
     */
    function fromFixed(int256 x)
        public
        pure
        returns (int256)
    {
        return x / fixed1();
    }

    /**
     * @notice Converts an int256 which is already in some fixed point 
     * representation to a different fixed precision representation.
     * Both the origin and destination precisions must be 38 or less digits.
     * Origin values with a precision higher than the destination precision
     * will be truncated accordingly.
     * @dev 
     * Test convertFixed(1,0,0) returns 1;
     * Test convertFixed(1,1,1) returns 1;
     * Test convertFixed(1,1,0) returns 0;
     * Test convertFixed(1,0,1) returns 10;
     * Test convertFixed(10,1,0) returns 1;
     * Test convertFixed(10,0,1) returns 100;
     * Test convertFixed(100,1,0) returns 10;
     * Test convertFixed(100,0,1) returns 1000;
     * Test convertFixed(1000,2,0) returns 10;
     * Test convertFixed(1000,0,2) returns 100000;
     * Test convertFixed(1000,2,1) returns 100;
     * Test convertFixed(1000,1,2) returns 10000;
     * Test convertFixed(maxInt256,1,0) returns maxInt256/10;
     * Test convertFixed(maxInt256,0,1) throws
     * Test convertFixed(maxInt256,38,0) returns maxInt256/(10**38);
     * Test convertFixed(1,0,38) returns 10**38;
     * Test convertFixed(maxInt256,39,0) throws
     * Test convertFixed(1,0,39) throws
     */
    function convertFixed(int256 x, uint8 _originDigits, uint8 _destinationDigits)
        public
        pure
        returns (int256)
    {
        assert(_originDigits <= 38 && _destinationDigits <= 38);
        
        uint8 decimalDifference;
        if ( _originDigits > _destinationDigits ){
            decimalDifference = _originDigits - _destinationDigits;
            return x/(uint128(10)**uint128(decimalDifference));
        }
        else if ( _originDigits < _destinationDigits ){
            decimalDifference = _destinationDigits - _originDigits;
            // Cast uint8 -> uint128 is safe
            // Exponentiation is safe:
            //     _originDigits and _destinationDigits limited to 38 or less
            //     decimalDifference = abs(_destinationDigits - _originDigits)
            //     decimalDifference < 38
            //     10**38 < 2**128-1
            assert(x <= maxInt256()/uint128(10)**uint128(decimalDifference));
            assert(x >= minInt256()/uint128(10)**uint128(decimalDifference));
            return x*(uint128(10)**uint128(decimalDifference));
        }
        // _originDigits == digits()) 
        return x;
    }

    /**
     * @notice Converts an int256 which is already in some fixed point 
     * representation to that of this library. The _originDigits parameter is the
     * precision of x. Values with a precision higher than FixidityLib.digits()
     * will be truncated accordingly.
     */
    function newFixed(int256 x, uint8 _originDigits)
        public
        pure
        returns (int256)
    {
        return convertFixed(x, _originDigits, digits());
    }

    /**
     * @notice Converts an int256 in the fixed point representation of this 
     * library to a different representation. The _destinationDigits parameter is the
     * precision of the output x. Values with a precision below than 
     * FixidityLib.digits() will be truncated accordingly.
     */
    function fromFixed(int256 x, uint8 _destinationDigits)
        public
        pure
        returns (int256)
    {
        return convertFixed(x, digits(), _destinationDigits);
    }

    /**
     * @notice Converts two int256 representing a fraction to fixed point units,
     * equivalent to multiplying dividend and divisor by 10^digits().
     * @dev 
     * Test newFixedFraction(maxFixedDiv()+1,1) fails
     * Test newFixedFraction(1,maxFixedDiv()+1) fails
     * Test newFixedFraction(1,0) fails     
     * Test newFixedFraction(0,1) returns 0
     * Test newFixedFraction(1,1) returns fixed1()
     * Test newFixedFraction(maxFixedDiv(),1) returns maxFixedDiv()*fixed1()
     * Test newFixedFraction(1,fixed1()) returns 1
     * Test newFixedFraction(1,fixed1()-1) returns 0
     */
    function newFixedFraction(
        int256 numerator, 
        int256 denominator
        )
        public
        pure
        returns (int256)
    {
        assert(numerator <= maxNewFixed());
        assert(denominator <= maxNewFixed());
        assert(denominator != 0);
        int256 convertedNumerator = newFixed(numerator);
        int256 convertedDenominator = newFixed(denominator);
        return divide(convertedNumerator, convertedDenominator);
    }

    /**
     * @notice Returns the integer part of a fixed point number.
     * @dev 
     * Test integer(0) returns 0
     * Test integer(fixed1()) returns fixed1()
     * Test integer(newFixed(maxNewFixed())) returns maxNewFixed()*fixed1()
     * Test integer(-fixed1()) returns -fixed1()
     * Test integer(newFixed(-maxNewFixed())) returns -maxNewFixed()*fixed1()
     */
    function integer(int256 x) public pure returns (int256) {
        return (x / fixed1()) * fixed1(); // Can't overflow
    }

    /**
     * @notice Returns the fractional part of a fixed point number. 
     * In the case of a negative number the fractional is also negative.
     * @dev 
     * Test fractional(0) returns 0
     * Test fractional(fixed1()) returns 0
     * Test fractional(fixed1()-1) returns 10^24-1
     * Test fractional(-fixed1()) returns 0
     * Test fractional(-fixed1()+1) returns -10^24-1
     */
    function fractional(int256 x) public pure returns (int256) {
        return x - (x / fixed1()) * fixed1(); // Can't overflow
    }

    /**
     * @notice Converts to positive if negative.
     * Due to int256 having one more negative number than positive numbers 
     * abs(minInt256) reverts.
     * @dev 
     * Test abs(0) returns 0
     * Test abs(fixed1()) returns -fixed1()
     * Test abs(-fixed1()) returns fixed1()
     * Test abs(newFixed(maxNewFixed())) returns maxNewFixed()*fixed1()
     * Test abs(newFixed(minNewFixed())) returns -minNewFixed()*fixed1()
     */
    function abs(int256 x) public pure returns (int256) {
        if (x >= 0) {
            return x;
        } else {
            int256 result = -x;
            assert (result > 0);
            return result;
        }
    }

    /**
     * @notice x+y. If any operator is higher than maxFixedAdd() it 
     * might overflow.
     * In solidity maxInt256 + 1 = minInt256 and viceversa.
     * @dev 
     * Test add(maxFixedAdd(),maxFixedAdd()) returns maxInt256()-1
     * Test add(maxFixedAdd()+1,maxFixedAdd()+1) fails
     * Test add(-maxFixedSub(),-maxFixedSub()) returns minInt256()
     * Test add(-maxFixedSub()-1,-maxFixedSub()-1) fails
     * Test add(maxInt256(),maxInt256()) fails
     * Test add(minInt256(),minInt256()) fails
     */
    function add(int256 x, int256 y) public pure returns (int256) {
        int256 z = x + y;
        if (x > 0 && y > 0) assert(z > x && z > y);
        if (x < 0 && y < 0) assert(z < x && z < y);
        return z;
    }

    /**
     * @notice x-y. You can use add(x,-y) instead. 
     * @dev Tests covered by add(x,y)
     */
    function subtract(int256 x, int256 y) public pure returns (int256) {
        return add(x,-y);
    }

    /**
     * @notice x*y. If any of the operators is higher than maxFixedMul() it 
     * might overflow.
     * @dev 
     * Test multiply(0,0) returns 0
     * Test multiply(maxFixedMul(),0) returns 0
     * Test multiply(0,maxFixedMul()) returns 0
     * Test multiply(maxFixedMul(),fixed1()) returns maxFixedMul()
     * Test multiply(fixed1(),maxFixedMul()) returns maxFixedMul()
     * Test all combinations of (2,-2), (2, 2.5), (2, -2.5) and (0.5, -0.5)
     * Test multiply(fixed1()/mulPrecision(),fixed1()*mulPrecision())
     * Test multiply(maxFixedMul()-1,maxFixedMul()) equals multiply(maxFixedMul(),maxFixedMul()-1)
     * Test multiply(maxFixedMul(),maxFixedMul()) returns maxInt256() // Probably not to the last digits
     * Test multiply(maxFixedMul()+1,maxFixedMul()) fails
     * Test multiply(maxFixedMul(),maxFixedMul()+1) fails
     */
    function multiply(int256 x, int256 y) public pure returns (int256) {
        if (x == 0 || y == 0) return 0;
        if (y == fixed1()) return x;
        if (x == fixed1()) return y;

        // Separate into integer and fractional parts
        // x = x1 + x2, y = y1 + y2
        int256 x1 = integer(x) / fixed1();
        int256 x2 = fractional(x);
        int256 y1 = integer(y) / fixed1();
        int256 y2 = fractional(y);
        
        // (x1 + x2) * (y1 + y2) = (x1 * y1) + (x1 * y2) + (x2 * y1) + (x2 * y2)
        int256 x1y1 = x1 * y1;
        if (x1 != 0) assert(x1y1 / x1 == y1); // Overflow x1y1
        
        // x1y1 needs to be multiplied back by fixed1
        // solium-disable-next-line mixedcase
        int256 fixed_x1y1 = x1y1 * fixed1();
        if (x1y1 != 0) assert(fixed_x1y1 / x1y1 == fixed1()); // Overflow x1y1 * fixed1
        x1y1 = fixed_x1y1;

        int256 x2y1 = x2 * y1;
        if (x2 != 0) assert(x2y1 / x2 == y1); // Overflow x2y1

        int256 x1y2 = x1 * y2;
        if (x1 != 0) assert(x1y2 / x1 == y2); // Overflow x1y2

        x2 = x2 / mulPrecision();
        y2 = y2 / mulPrecision();
        int256 x2y2 = x2 * y2;
        if (x2 != 0) assert(x2y2 / x2 == y2); // Overflow x2y2

        // result = fixed1() * x1 * y1 + x1 * y2 + x2 * y1 + x2 * y2 / fixed1();
        int256 result = x1y1;
        result = add(result, x2y1); // Add checks for overflow
        result = add(result, x1y2); // Add checks for overflow
        result = add(result, x2y2); // Add checks for overflow
        return result;
    }
    
    /**
     * @notice 1/x
     * @dev 
     * Test reciprocal(0) fails
     * Test reciprocal(fixed1()) returns fixed1()
     * Test reciprocal(fixed1()*fixed1()) returns 1 // Testing how the fractional is truncated
     * Test reciprocal(2*fixed1()*fixed1()) returns 0 // Testing how the fractional is truncated
     */
    function reciprocal(int256 x) public pure returns (int256) {
        assert(x != 0);
        return (fixed1()*fixed1()) / x; // Can't overflow
    }

    /**
     * @notice x/y. If the dividend is higher than maxFixedDiv() it 
     * might overflow. You can use multiply(x,reciprocal(y)) instead.
     * There is a loss of precision on division for the lower mulPrecision() decimals.
     * @dev 
     * Test divide(fixed1(),0) fails
     * Test divide(maxFixedDiv(),1) = maxFixedDiv()*(10^digits())
     * Test divide(maxFixedDiv()+1,1) throws
     * Test divide(maxFixedDiv(),maxFixedDiv()) returns fixed1()
     */
    function divide(int256 x, int256 y) public pure returns (int256) {
        if (y == fixed1()) return x;
        assert(y != 0);
        assert(y <= maxFixedDivisor());
        return multiply(x, reciprocal(y));
    }
}


// File contracts/libraries/Utils.sol


pragma solidity ^0.6.4;
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
        out = (val < 0) ? 
            string(abi.encodePacked("-", uint256(val.mul(-1)).toString())) :
            uint256(val).toString();
    }

    function zeroPad(int256 value, uint256 places) internal pure returns (string memory out) {
        out = toString(value);
        for (uint i=(places-1); i>0; i--)
            if (value < int256(10**i))
                out = string(abi.encodePacked("0", out));
    }
}


// File @openzeppelin/contracts/utils/SafeCast.sol@v3.1.0



pragma solidity ^0.6.0;


/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}


// File contracts/libraries/Random.sol


pragma solidity ^0.6.4;
library Random {
    using SafeMath for uint256;
    using SignedSafeMath for int256;

    /**
     * Initialize the pool with the entropy of the blockhashes of the num of blocks starting from 0
     * The argument "seed" allows you to select a different sequence of random numbers for the same block range.
     */
    function init(
        uint256 seed
    ) internal view returns (bytes32[] memory) {
        uint256 blocks = 2;
        bytes32[] memory pool = new bytes32[](3);
        bytes32 salt = keccak256(abi.encodePacked(uint256(0), seed));
        for (uint256 i = 0; i < blocks; i++) {
            // Add some salt to each blockhash
            pool[i + 1] = keccak256(
                abi.encodePacked(blockhash(i), salt)
            );
        }
        return pool;
    }

    /**
     * Advances to the next 256-bit random number in the pool of hash chains.
     */
    function next(bytes32[] memory pool) internal pure returns (uint256) {
        require(pool.length > 1, "Random.next: invalid pool");
        uint256 roundRobinIdx = (uint256(pool[0]) % (pool.length - 1)) + 1;
        bytes32 hash = keccak256(abi.encodePacked(pool[roundRobinIdx]));
        pool[0] = bytes32(uint256(pool[0]) + 1);
        pool[roundRobinIdx] = hash;
        return uint256(hash);
    }

    /**
     * Produces random integer values, uniformly distributed on the closed interval [a, b]
     */
    function uniform(
        bytes32[] memory pool,
        int256 a,
        int256 b
    ) internal pure returns (int256) {
        require(a <= b, "Random.uniform: invalid interval");
        return int256(next(pool) % uint256(b - a + 1)) + a;
    }

    /**
     * Produces random integer values, with weighted distributions for values in a set
     */
    function weighted(
        bytes32[] memory pool,
        uint8[7] memory thresholds,
        uint16 total
    ) internal pure returns (uint8) {
        int256 p = uniform(pool, 1, total);
        int256 s = 0;
        for (uint8 i=0; i<7; i++) {
            s = s.add(thresholds[i]);
            if (p <= s) return i;
        }
    }

    /**
     * Produces random integer values, with weighted distributions for values in a set
     */
    function weighted(
        bytes32[] memory pool,
        uint8[24] memory thresholds,
        uint16 total
    ) internal pure returns (uint8) {
        int256 p = uniform(pool, 1, total);
        int256 s = 0;
        for (uint8 i=0; i<24; i++) {
            s = s.add(thresholds[i]);
            if (p <= s) return i;
        }
    }
}


// File contracts/libraries/Colors.sol


pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

library Colors {
    using Strings for *;
    using SafeCast for *;
    using SafeMath for *;
    using Random for bytes32[];

    function toString(HSL calldata color) external pure returns (string memory) {
        return string(abi.encodePacked("hsl(", uint256(color.hue).toString(), ",", uint256(color.saturation).toString(), "%,", uint256(color.lightness).toString(), "%)"));
    }
    
    function lookupHue(
        uint16 rootHue,
        uint8 scheme,
        uint8 index
    ) internal pure returns (uint16 hue) {
        uint16[3][10] memory schemes = [
            [uint16(30), uint16(330), uint16(0)], // analogous
            [uint16(120), uint16(240), uint16(0)], // triadic
            [uint16(180), uint16(180), uint16(0)], // complimentary
            [uint16(60), uint16(180), uint16(240)], // tetradic
            [uint16(30), uint16(180), uint16(330)], // analogous and complimentary
            [uint16(150), uint16(210), uint16(0)], // split complimentary
            [uint16(150), uint16(180), uint16(210)], // complimentary and analogous
            [uint16(30), uint16(60), uint16(90)], // series
            [uint16(90), uint16(180), uint16(270)], // square
            [uint16(0), uint16(0), uint16(0)] // mono
        ];

        require(scheme < schemes.length, "Invalid scheme id");
        require(index < 4, "Invalid color index");

        hue = index == 0 ? rootHue : uint16(rootHue.mod(360).add(schemes[scheme][index-1]));
    }

    function lookupColor(
        uint8 scheme,
        uint16 hue,
        uint8 saturation,
        uint8 lightness,
        uint8 shades,
        uint8 contrast,
        uint8 shade,
        uint8 hueIndex
    ) external pure returns (HSL memory) {
        uint16 h = lookupHue(hue, scheme, hueIndex);
        uint8 s = saturation;
        uint8 l = calcShade(lightness, shades, contrast, shade);
        return HSL(h, s, l);
    }

    function calcShade(
        uint8 lightness,
        uint8 shades,
        uint8 contrast,
        uint8 shade
    ) public pure returns (uint8 l) {
        if (shades > 1) {
            uint256 range = uint256(contrast);
            uint256 step = range.div(uint256(shades));
            uint256 offset = uint256(shade.mul(step));
            l = uint8(uint256(lightness).sub(offset));
        } else {
            l = lightness;
        }
    }

    /**
     * @dev parse the bkg value into an HSL color
     * @param bkg settings packed int 8 bits
     * @return HSL color style CSS string
     */
    function _parseBkg(uint8 bkg) external pure returns (string memory) {
        uint256 hue = (bkg / 16) * 24;
        uint256 sat = hue == 0 ? 0 : (((bkg / 4) % 4) + 1) * 25;
        uint256 lit = hue == 0 ? (625 * (bkg % 16)) / 100 : ((bkg % 4) + 1) * 20;
        return string(abi.encodePacked(
            "background-color:hsl(",
            hue.toString(), ",",
            sat.toString(), "%,",
            lit.toString(), "%);"
        ));
    }
}


// File contracts/libraries/SVG.sol


pragma solidity ^0.6.4;
library SVG {
    using Utils for *;
    using Colors for *;
    using Strings for *;

    /**
     * @dev render a rectangle SVG tag with nested content
     * @param shape object
     * @param slot for nested tags (animations)
     */
    function _rect(Shape memory shape, string memory slot) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<rect x="',
            shape.position[0].toString(),
            '" y="',
            shape.position[1].toString(),
            '" width="',
            shape.size[0].toString(),
            '" height="',
            shape.size[1].toString(),
            '" transform-origin="300 300" style="fill:',
            shape.color.toString(),
            bytes(slot).length == 0 ?
                '"/>' :
                string(abi.encodePacked('">',slot,'</rect>'))
        ));
    }

    /**
     * @dev render an g(group) SVG tag with attributes
     * @param attr string for attributes
     * @param slot for nested group content
     */
    function _g(string memory attr, string memory slot) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<g', 
            bytes(attr).length == 0 ? '' : string(abi.encodePacked(' ',attr,' ')),
            '>',
            slot,
            '</g>'
        ));
    }

    /**
     * @dev render a use SVG tag
     * @param id of the new SVG use tag
     * @param link id of the SVG tag to reference
     */
    function _use(string memory link, string memory id) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<use ',
            bytes(id).length == 0 ? '' : string(abi.encodePacked(' id="',id,'" ')),
            'xlink:href="#',link,'"/>'
        ));
    }
    
    /**
     * @dev render the outer SVG markup. XML version, doctype and SVG tag
     * @param body of the SVG markup
     * @return header string
     */
    function _SVG(string memory bkgColor, string memory body) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<?xml version="1.0" encoding="UTF-8"?>',
            '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">',
            '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="100%" height="100%" viewBox="0 0 2400 2400" style="stroke-width:0;',
            bkgColor,
            'margin: auto;height: -webkit-fill-available">',
            body,
            '</svg>'
        ));
    }
}


// File contracts/libraries/Decimal.sol


pragma solidity ^0.6.4;
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


// File contracts/libraries/Animation.sol


pragma solidity ^0.6.4;

library Animation {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using DecimalUtils for *;
    using Utils for *;
    using Strings for *;

    /**
     * @dev render an animate SVG tag
     */
    function _animate(string memory attribute, string memory duration, string memory values, string memory attr) internal pure returns (string memory) {
        return _animate(attribute, duration, values, '', attr);
    }

    /**
     * @dev render an animate SVG tag
     */
    function _animate(string memory attribute, string memory duration, string memory values, string memory calcMode, string memory attr) internal pure returns (string memory) {
        return string(abi.encodePacked('<animate attributeName="', attribute, '" values="', values, '" dur="', duration,
        bytes(calcMode).length == 0 ? '' : string(abi.encodePacked('" calcMode="',calcMode)),
        '" ',attr,'/>'));
    }

    /**
     * @dev render an animate SVG tag with keyTimes and keySplines
     */
    function _animate(string memory attribute, string memory duration, string memory values, string memory keyTimes, string memory keySplines, string memory attr) internal pure returns (string memory) {
        return string(abi.encodePacked('<animate attributeName="', attribute, '" values="', values, '" dur="', duration,
        '" keyTimes="',keyTimes,'" keySplines="',keySplines,
        '" calcMode="spline" ',attr,'/>'));
    }

    /**
     * @dev render an animateTransform SVG tag with keyTimes and keySplines
     */
    function _animateTransform(string memory typeVal, string memory duration, string memory values, string memory keyTimes, string memory keySplines, string memory attr, bool add) internal pure returns (string memory) {
        return string(abi.encodePacked('<animateTransform attributeName="transform" attributeType="XML" type="', typeVal,'" dur="', duration, '" values="', values,
            bytes(keyTimes).length == 0 ? '' : string(abi.encodePacked('" keyTimes="', keyTimes)),
            bytes(keySplines).length == 0 ? '' : string(abi.encodePacked('" calcMode="spline" keySplines="', keySplines)),
            add ? '" additive="sum' : '',
        '" ',attr,'/>'));
    }

    /**
     * @dev render an animateTransform SVG tag with keyTimes
     */
    function _animateTransform(string memory typeVal, string memory duration, string memory values, string memory keyTimes, string memory attr, bool add) internal pure returns (string memory) {
        return _animateTransform(typeVal, duration, values, keyTimes, '', attr, add);
    }

    /**
     * @dev render an animateTransform SVG tag
     */
    function _animateTransform(string memory typeVal, string memory duration, string memory values, string memory attr, bool add) internal pure returns (string memory) {
        return _animateTransform(typeVal, duration, values, '', '', attr, add);
    }

    /**
     * @dev render an animateTransform SVG tag with keyTimes
     */
    function _animateTransform(string memory typeVal, string memory duration, string memory values, string memory keyTimes, string memory keySplines, string memory attr) internal pure returns (string memory) {
        return _animateTransform(typeVal, duration, values, keyTimes, keySplines, attr, false);
    }

    /**
     * @dev render an animateTransform SVG tag with keyTimes
     */
    function _animateTransform(string memory typeVal, string memory duration, string memory values, string memory keyTimes, string memory attr) internal pure returns (string memory) {
        return _animateTransform(typeVal, duration, values, keyTimes, '', attr, false);
    }

    /**
     * @dev render an animateTransform SVG tag
     */
    function _animateTransform(string memory typeVal, string memory duration, string memory values, string memory attr) internal pure returns (string memory) {
        return _animateTransform(typeVal, duration, values, '', '', attr, false);
    }

    // /**
    //  * @dev creata a keyTimes string, based on a range and division count
    //  */
    // function generateTimes() internal pure returns (string memory times) {}

    /**
     * @dev creata a keySplines string, with a bezier curve for each value transition
     */
    function generateSplines(uint8 transitions, uint8 curve) internal pure returns (string memory curves) {
        string[2] memory bezierCurves = [
            ".5 0 .75 1", // ease in and out fast
            ".4 0 .6 1" // ease in fast + soft
        ];
        for (uint8 i=0; i < transitions; i++)
            curves = string(abi.encodePacked(curves, i>0 ? ";" : "", bezierCurves[curve]));
    }

    /**
     * @dev calculate attributes for an animation tag based of the animation mode
     */
    function _calcAttributes(uint256 mode) internal pure returns (string memory) {
        uint8[3] memory counts = [1,2,25];
        string memory repeat = string(abi.encodePacked(
            'repeatCount="',
            mode <= 4 ? 'indefinite' : uint256(counts[mode-5]).toString(),
            '" '
        ));
        string memory begin = mode <= 1 ? '' : string(abi.encodePacked(
            'begin="target.',
            mode == 2 ? 'mouseenter ' : mode == 3 ? 'dblclick' : 'click',
            '" '
        ));
        string memory end = mode == 2 ? 'end="target.mouseleave" ' :
            mode == 3 ? 'end="target.click" ' : '';
        return string(abi.encodePacked(repeat, begin, end));
        // 0 - 000    '',
        // 1 - 001    'repeatCount="indefinite" ',
        // 2 - 010    'repeatCount="indefinite" begin="target.mouseenter" ',
        // 4 - 100    'repeatCount="indefinite" begin="target.dblclick" end="target.click" ',
        // 3 - 011    'repeatCount="indefinite" begin="target.click" ',
        // 5 - 101    'repeatCount="1" begin="target.click" ',
        // 6 - 110    'repeatCount="2" begin="target.click" ',
        // 7 - 111    'repeatCount="25" begin="target.click" '
    }

    /**
     * @dev select the animation
     * @param box object to base animation around
     * @param shapeIndex index of the shape to animate
     * @return mod struct of modulator values
     */
    function _generateAnimation(
        TinyBox calldata box,
        uint8 animation,
        Shape calldata shape,
        uint256 shapeIndex
    ) external pure returns (string memory) {
        string memory duration = string(abi.encodePacked(uint256(box.duration > 0 ? box.duration : 10).toString(),"s"));
        string memory attr = _calcAttributes(box.options%8);
        // select animation based on animation id
        if (animation == 0) {
            // snap spin 90
            return _animateTransform(
                "rotate", duration, "0;90;90;360;360", "0;.2;.3;.9;1", generateSplines(4,0), attr
            );
        } else if (animation == 1) {
            // snap spin 180
            return _animateTransform(
                "rotate", duration, "0;180;180;360;360", "0;.4;.5;.9;1", generateSplines(4,0), attr
            );
        } else if (animation == 2) {
            // snap spin 270
            return _animateTransform(
                "rotate", duration, "0;270;270;360;360", "0;.6;.7;.9;1", generateSplines(4,0), attr
            );
        } else if (animation == 3) {
            // snap spin tri
            return _animateTransform(
                "rotate", duration, "0;120;120;240;240;360;360", "0;.166;.333;.5;.666;.833;1",
                generateSplines(6,0), attr
            );
        } else if (animation == 4) {
            // snap spin quad
            return _animateTransform(
                "rotate", duration, "0;90;90;180;180;270;270;360;360", "0;.125;.25;.375;.5;.625;.8;.925;1",
                generateSplines(8,0), attr
            );
        } else if (animation == 5) {
            // snap spin tetra
            return _animateTransform(
                "rotate", duration, "0;72;72;144;144;216;216;278;278;360;360", "0;.1;.2;.3;.4;.5;.6;.7;.8;.9;1",
                generateSplines(10,0), attr
            );
        } else if (animation == 6) {
            // Uniform Speed Spin
            return _animateTransform( "rotate", duration, "0;360", "0;1", attr );
        } else if (animation == 7) {
            // 2 Speed Spin
            return _animateTransform( "rotate", duration, "0;90;270;360", "0;.1;.9;1", attr );
        } else if (animation == 8) {
            // indexed speed
            return _animateTransform(
                "rotate",
                string(abi.encodePacked(uint256(((1000*(box.duration > 0 ? box.duration : 10)) / box.shapes) * (shapeIndex + 1) ).toString(),"ms")),
                "0;360",
                "0;1",
                attr
            );
        } else if (animation == 9) {
            // spread
            uint256 spread = uint256(300).div(uint256(box.shapes));
            string memory angle = shapeIndex.add(1).mul(spread).toString();
            string memory values = string(abi.encodePacked("0;",  angle, ";",  angle, ";360;360"));
            return _animateTransform( "rotate", duration, values, "0;.5;.6;.9;1", generateSplines(4,0), attr );
        } else if (animation == 10) {
            // spread w time
            string memory angle = shapeIndex.add(1).mul(uint256(300).div(uint256(box.shapes))).toString();
            uint256 timeShift = uint256(900).sub(uint256(box.shapes).sub(shapeIndex).mul(uint256(800).div(uint256(box.shapes))));
            string memory times = string(abi.encodePacked("0;.",timeShift.toString(),";.9;1"));
            return _animateTransform( "rotate", duration, string(abi.encodePacked("0;",angle,";",angle,";360")), times, generateSplines(3,0), attr );
        } else if (animation == 11) {
            // jitter
            int256[2] memory amp = [int256(10), int256(10)]; // randomize amps for each shape?
            string[2] memory vals;
            for (uint256 i = 0; i < 2; i++) {
                int256 pos = shape.position[i];
                string memory min = pos.sub(amp[i]).toString();
                string memory max = pos.add(amp[i]).toString();
                vals[i] = string(abi.encodePacked(
                    (i==0) ? min : max, ";", (i==0) ? max : min
                ));
            }
            return string(abi.encodePacked(
                _animate("x",string(abi.encodePacked(uint256(box.duration > 0 ? box.duration : 10).div(10).toString(),"s")),vals[0],"discrete", attr),
                _animate("y",string(abi.encodePacked(uint256(box.duration > 0 ? box.duration : 10).div(5).toString(),"s")),vals[1],"discrete", attr)
            ));
        } else if (animation == 12) {
            // giggle
            int256 amp = 5;
            string[2] memory vals;
            for (uint256 i = 0; i < 2; i++) {
                int256 pos = shape.position[i];
                string memory min = pos.sub(amp).toString();
                string memory max = pos.add(amp).toString();
                vals[i] = string(abi.encodePacked(
                    (i==0) ? min : max, ";", (i==0) ? max : min, ";", (i==0) ? min : max
                ));
            }
            return string(abi.encodePacked(
                _animate("x", string(abi.encodePacked(uint256(box.duration > 0 ? box.duration : 10).mul(20).toString(),"ms")),vals[0], attr),
                _animate("y", string(abi.encodePacked(uint256(box.duration > 0 ? box.duration : 10).mul(20).toString(),"ms")),vals[1], attr)
            ));
        } else if (animation == 13) {
            // jolt
            int256 amp = 5;
            string[2] memory vals;
            for (uint256 i = 0; i < 2; i++) {
                int256 pos = shape.position[i];
                string memory min = pos.sub(amp).toString();
                string memory max = pos.add(amp).toString();
                vals[i] = string(abi.encodePacked(
                    (i==0) ? min : max, ";", (i==0) ? max : min
                ));
            }
            return string(abi.encodePacked(
                _animate("x", string(abi.encodePacked(uint256(box.duration > 0 ? box.duration : 10).mul(25).toString(),"ms")),vals[0], attr),
                _animate("y", string(abi.encodePacked(uint256(box.duration > 0 ? box.duration : 10).mul(25).toString(),"ms")),vals[1], attr)
            ));
        } else if (animation == 14) {
            // grow n shrink
            return _animateTransform( "scale", duration, "1 1;1.5 1.5;1 1;.5 .5;1 1", "0;.25;.5;.75;1" );
        } else if (animation == 15) {
            // squash n stretch
            uint256 div = 7;
            string[2] memory vals;
            for (uint256 i = 0; i < 2; i++) {
                uint256 size = uint256(shape.size[i]);
                string memory avg = size.toString();
                string memory min = size.sub(size.div(div)).toString();
                string memory max = size.add(size.div(div)).toString();
                vals[i] = string(abi.encodePacked(
                    avg, ";", (i==0) ? min : max, ";", avg, ";", (i==0) ? max : min, ";", avg
                ));
            }
            return string(abi.encodePacked(
                _animate("width",duration,vals[0], attr),
                _animate("height",duration,vals[1], attr)
            ));
        } else if (animation == 16) {
            // Rounding corners
            return _animate("rx",duration,"0;100;0", attr);
        } else if (animation == 17) {
            // glide
            int256 amp = 20;
            string memory max = int256(0).add(amp).toString();
            string memory min = int256(0).sub(amp).toString();
            string memory values = string(abi.encodePacked( "0 0;", min, " ", min, ";0 0;", max, " ", max, ";0 0" ));
            return _animateTransform("translate",duration,values, attr);
        } else if (animation == 18) {
            // Wave
            string memory values = string(abi.encodePacked("1 1;1 1;1.5 1.5;1 1;1 1"));
            int256 div = int256(10000).div(int256(box.shapes + 1));
            int256 peak = int256(10000).sub(div.mul(int256(shapeIndex).add(1)));
            string memory mid = peak.toDecimal(4).toString();
            string memory start = peak.sub(div).toDecimal(4).toString();
            string memory end = peak.add(div).toDecimal(4).toString();
            string memory times = string(abi.encodePacked("0;", start, ";", mid, ";", end, ";1")); 
            return _animateTransform( "scale", duration, values, times, generateSplines(4,0), attr );
        } else if (animation == 19) {
            // Phased Fade
            uint256 fadeOut = uint256(box.shapes).sub(shapeIndex).mul(uint256(400).div(uint256(box.shapes)));
            uint256 fadeIn = uint256(900).sub(uint256(box.shapes).sub(shapeIndex).mul(uint256(400).div(uint256(box.shapes))));
            string memory times = string(abi.encodePacked("0;.", fadeOut.toString(), ";.", fadeIn.toString(), ";1"));
            return _animate("opacity", duration, "1;0;0;1", times, generateSplines(3,0), attr );
        } else if (animation == 20) {
            // Skew X
            return _animateTransform( "skewX", duration, "0;50;-50;0", attr );
        } else if (animation == 21) {
            // Skew Y
            return _animateTransform( "skewY", duration, "0;50;-50;0", attr );
        } else if (animation == 22) {
            // Stretch - (bounce skewX w/ ease-in-out)
            return _animateTransform(
                "skewX", string(abi.encodePacked(uint256(box.duration > 0 ? box.duration : 10).div(2).toString(),"s")), "0;-64;32;-16;8;-4;2;-1;.5;0;0", "0;.1;.2;.3;.4;.5;.6;.7;.8;.9;1", generateSplines(10,0), attr
            );
        } else if (animation == 23) {
            // Jello - (bounce skewX w/ ease-in)
            return _animateTransform(
                "skewX", duration, "0;16;-12;8;-4;2;-1;.5;-.25;0;0", "0;.1;.2;.3;.4;.5;.6;.7;.8;.9;1", generateSplines(10,1), attr
            );
        }
    }
}


// File @openzeppelin/contracts/math/Math.sol@v3.1.0



pragma solidity ^0.6.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


// File contracts/libraries/Metadata.sol


pragma solidity ^0.6.4;
library Metadata {
    using Math for uint256;
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using Random for bytes32[];
    using DecimalUtils for *;
    using Utils for *;
    using Colors for *;
    using Strings for *;

    function toString(address account) public pure returns(string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(uint256 value) public pure returns(string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes32 value) public pure returns(string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes memory data) public pure returns(string memory) {
        bytes memory alphabet = "0123456789ABCDEF";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    /**
     * @dev render the header of the SVG markup
     * @return header string
     */
    function _generateColorMetadata(TinyBox memory box, uint8[4] memory dVals) internal pure returns (string memory) {
        string memory rootHue = string(abi.encodePacked('<hue>', uint256(box.hue).toString(), '</hue>'));
        string memory saturation = string(abi.encodePacked('<saturation>', uint256(box.saturation).toString(), '</saturation>'));
        string memory lightness = string(abi.encodePacked('<lightness>', uint256(box.lightness).toString(), '</lightness>'));
        string memory scheme = string(abi.encodePacked('<scheme>', uint256(dVals[1]).toString(), '</scheme>'));
        string memory shades = string(abi.encodePacked('<shades>', uint256(dVals[2]).toString(), '</shades>'));
        string memory contrast = string(abi.encodePacked('<contrast>', uint256(dVals[3]).toString(), '</contrast>'));

        return string(abi.encodePacked(
            '<color>',
            rootHue, saturation, lightness, scheme, shades, contrast,
            '</color>'
        ));
    }
    
    /**
     * @dev render the header of the SVG markup
     * @return header string
     */
    function _generateShapesMetadata(TinyBox memory box) internal pure returns (string memory) {
        string memory size = string(abi.encodePacked(
            '<width>', uint256(box.widthMin).toString(), '-', uint256(box.widthMax).toString(), '</width>',
            '<height>', uint256(box.heightMin).toString(), '-', uint256(box.heightMax).toString(), '</height>'
        ));
        return string(abi.encodePacked(
            '<shapes>',
                '<count>', uint256(box.shapes).toString(), '</count>',
                '<hatching>', uint256(box.hatching).toString(), '</hatching>',
                '<size>', size, '</size>',
            '</shapes>'
        ));
    }
    
    /**
     * @dev render the header of the SVG markup
     * @return header string
     */
    function _generatePlacementMetadata(TinyBox memory box) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<placement>',
                '<rows>', uint256(box.grid % 16).toString(), '</rows>',
                '<columns>', uint256(box.grid / 16).toString(), '</columns>',
                '<spread>', uint256(box.spread).toString(), '</spread>',
            '</placement>'
        ));
    }
    
    /**
     * @dev render the header of the SVG markup
     * @return header string
     */
    function _generateMirrorMetadata(TinyBox memory box) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<mirror>',
                '<mirror-mode>',
                    uint256(box.mirroring).toString(),
                '</mirror-mode>',
            '</mirror>'
        ));
    }

    /**
     * @dev render the header of the SVG markup
     * @return header string
     */
    function _generateMetadata(TinyBox memory box, uint8[4] memory dVals, uint256 id, address owner) internal view returns (string memory) {
        string memory colors = _generateColorMetadata(box, dVals);
        string memory shapes = _generateShapesMetadata(box);
        string memory placement = _generatePlacementMetadata(box);
        string memory mirror = _generateMirrorMetadata(box);

        string memory animation = string(abi.encodePacked(
            '<animated>',
                (box.options % 2 == 1) ? 'true' : 'false',
            '</animated>',
            '<animation>',
                uint256(dVals[0]).toString(),
            '</animation>'
        ));

        string memory token = id >= 0 ? string(abi.encodePacked(
            '<token>',
                '<id>',
                    id.toString(),
                '</id>',
                '<owner>',
                    toString(owner),
                '</owner>',
            '</token>'
        )) : '';

        string memory contractAddress = string(abi.encodePacked(
            '<contract>',
                toString(address(this)),
            '</contract>'
        ));

        string memory settings = string(abi.encodePacked(
            '<settings>',
                '<bkg>',
                    uint256(box.bkg).toString(),
                '</bkg>',
                '<duration>',
                    uint256(box.duration).toString(),
                '</duration>',
                '<options>',
                    uint256(box.options).toString(),
                '</options>',
            '</settings>'
        ));

        string memory renderedAt = string(abi.encodePacked('<rendered-at>',now.toString(),'</rendered-at>'));

        return string(abi.encodePacked('<metadata>', contractAddress, renderedAt, token, settings, animation, colors, shapes, placement, mirror, '</metadata>'));
    }
}


// File contracts/TinyBoxRenderer.sol


pragma solidity ^0.6.8;

contract TinyBoxRenderer {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using Random for bytes32[];
    using Metadata for TinyBox;
    using Animation for TinyBox;
    using Strings for *;
    using Colors for *;
    using SVG for *;
    using Utils for *;

    /**
     * @dev generate a shape
     * @param pool randomn numbers pool
     * @param spacing for shapes
     * @param size of shapes
     * @param hatched mode bool switch
     * @return positions of shape
     */
    function _generateBox(
        bytes32[] memory pool,
        uint8[2] memory spacing,
        uint8[4] memory size,
        bool hatched
    )
        internal
        pure
        returns (int256[2] memory positions, int256[2] memory dimensions)
    {
        // PRNG for box position
        int256[2] memory grid = [
            int256(uint256(spacing[1]).mod(16)).add(1),
            int256(uint256(spacing[1]).div(16)).add(1)
        ];
        positions = [
            pool.uniform( -(int256(600).div(grid[0].add(1)).div(200).mul(int256(spacing[0]))), (int256(600).div(grid[0].add(1)).div(200).mul(int256(spacing[0])))).add(
            (int256(600).div(grid[0].add(1)).mul(pool.uniform(0, grid[0])))),
            pool.uniform( -(int256(600).div(grid[1].add(1)).div(200).mul(int256(spacing[0]))), (int256(600).div(grid[1].add(1)).div(200).mul(int256(spacing[0])))).add(
            (int256(600).div(grid[1].add(1)).mul(pool.uniform(0, grid[1]))))
        ];
        // PRNG for box size
        if (hatched) {
            int256 horizontal = pool.uniform(0, 1);
            int256 width = pool.uniform(25, 40).add(int256(500).mul(horizontal));
            dimensions = [
                width,
                pool.uniform(10, 25).add(int256(540).sub(width))
            ];
        } else
            dimensions = [
                pool.uniform(int256(size[0]), int256(size[1])),
                pool.uniform(int256(size[2]), int256(size[3]))
            ];
    }

    /**
     * @dev generate a shape
     * @param index of the shape
     * @param box data to make a shape from
     * @param dVals deterministicaly calculated values
     * @return positions of shape
     */
    function _generateShape(
        bytes32[] memory pool,
        uint256 index,
        TinyBox memory box,
        uint8[4] memory dVals
    )
        internal
        view
        returns (Shape memory)
    {
        // calculate hatching switch
        bool hatching = (
            box.hatching > 0 &&
            uint256(index).mod(box.hatching) == 0
        );
        // generate a shapes position and size using box parameters
        (
            int256[2] memory position,
            int256[2] memory size
        ) = _generateBox(pool, [box.spread, box.grid], [box.widthMin,box.widthMax,box.heightMin,box.heightMax], hatching);
        // lookup a random color from the color palette
        uint8 hue = uint8(pool.uniform(0, 3));
        uint8 shade = uint8(pool.uniform(0, int256(dVals[2]).sub(1)));
        HSL memory color;
        if (dVals[1] == 10) {
            // seed the random scheme from the extra bit space of the rootHue
            bytes32[] memory huePool = Random.init(uint256(box.hue).div(360).add(hue));
            color = HSL(
                hue == 0 ? box.hue : uint16(huePool.uniform(0,359)),
                box.saturation,
                Colors.calcShade(box.lightness, dVals[2], dVals[3], shade)
            );
        } else {
            color = dVals[1].lookupColor(box.hue,box.saturation,box.lightness,dVals[2],dVals[3],shade,hue);
        }
        return Shape(position, size, color);
    }

    /**
     * @dev render the footer string for mirring effects
     * @param mirroring generator settings
     * @return footer string
     */
    function _generateMirroring(
        uint8 mirroring
    ) internal pure returns (string memory) {
        string[4] memory scales = ['1 1','-1 1','1 -1','-1 -1'];
        uint16[3] memory levels = [600, 1200, 2400];
        // reference shapes symbol at core of mirroring
        string memory symbols = string(abi.encodePacked('<symbol id="quad0">',SVG._g('', SVG._use('shapes','')),'</symbol>'));
        // loop through nested mirroring levels
        for (uint256 s = 0; s < 3; s++) {
            string memory id = string(abi.encodePacked('quad', s.toString()));
            string memory copies;
            // check this mirror levels mode
            string memory value = string(abi.encodePacked('-', uint256(levels[s]).toString()));
            // select mirriring type for this level
            uint8 m = uint8(uint256(mirroring).div(4**s).mod(4));
            bool[4] memory switches = [m != 2, m > 1, m > 1, m % 2 == 1];
            // generate mirrored copies
            for (uint8 i = 0; i < 4; i++) {
                if (switches[i]) {
                    string memory transform = string(abi.encodePacked(
                        'transform="scale(', scales[i], ') translate(', (i%2 == 1) ? value : '0', ' ', (i > 1) ? value : '0', ')"'
                    ));
                    copies = string(abi.encodePacked(copies,SVG._g(transform, SVG._use(id,''))));
                }
            }
            // wrap symbol and all copies in a new symbol
            symbols = string(abi.encodePacked('<symbol id="quad',(s+1).toString(),'">',symbols,copies,'</symbol>')); // wrap last level in a shape tag to refer to later
        }
        // add final scaling transform
        uint256 scale = uint256(mirroring).div(16) == 0 ? (uint256(mirroring).div(4) == 0 ? 4 : 2) : 1;
        string memory attrs = string(abi.encodePacked(
            'transform="scale(', scale.toString(), ' ', scale.toString(), ')" clip-path="url(#clip)"'
        ));
        string memory finalScale = SVG._g(attrs, SVG._use('quad3', ''));
        return string(abi.encodePacked(symbols,finalScale));
    }

    /**
     * @dev render TinyBox artwork
     * @param box TinyBox data structure
     * @param id of the token to render
     * @param owner of the token rendered
     * @param dVals deterministic vals for rendering
     * @param _slot string for embeding custom additions
     * @return markup of the SVG graphics of the token as a string
     */
    function perpetualRenderer(TinyBox memory box, uint256 id, address owner, uint8[4] memory dVals, string memory _slot)
        public
        view
        returns (string memory)
    {
        // seed PRNG
        bytes32[] memory pool = Random.init(box.randomness);

        // generate shapes (shapes + animations)
        string memory shapes = "";
        for (uint256 i = 0; i < uint256(box.shapes); i++) {
            Shape memory shape = _generateShape(pool, i, box, dVals);
            shapes = string(abi.encodePacked(shapes,
                SVG._rect(shape, (box.options%8 != 0) ?
                    box._generateAnimation(dVals[0],shape,i) : ''
                )
            ));
        }
        // wrap shapes in a symbol with the id "shapes"
        string memory defs = string(abi.encodePacked(
            _slot,
            '<defs><rect id="cover" width="100%" height="100%" fill="hsl(0,0%,0%,0%)" /><clipPath id="clip"><use xlink:href="#cover"/></clipPath><symbol id="shapes">',
            shapes,
            '</symbol></defs>'
        ));

        // build up the SVG markup
        return SVG._SVG(
            ((box.options/8)%2 == 1) ? "" : box.bkg._parseBkg(),
            string(abi.encodePacked(
                box._generateMetadata(dVals,id,owner),
                defs,
                _generateMirroring(box.mirroring),
                SVG._use('cover', 'target')
            ))
        );
    }
}
