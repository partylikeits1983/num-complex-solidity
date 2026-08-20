// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24 <0.9.0;

import { SD59x18, sd } from "@prb/math/src/SD59x18.sol";
import { msb, mulDiv, sqrt as sqrtUint } from "@prb/math/src/Common.sol";

import { Trigonometry } from "./Trigonometry.sol";

/// @notice A signed 59.18-decimal fixed-point complex number.
/// @param re Real component.
/// @param im Imaginary component.
struct Complex {
    SD59x18 re;
    SD59x18 im;
}

/// @title ComplexMath
/// @notice Gas-conscious complex arithmetic for signed 59.18-decimal fixed-point numbers.
/// @dev Functions are internal so the compiler can inline them into consuming contracts.
library ComplexMath {
    struct Uint512 {
        uint256 hi;
        uint256 lo;
    }

    struct Signed512 {
        Uint512 magnitude;
        bool negative;
    }

    struct Uint768 {
        uint256 hi;
        uint256 mid;
        uint256 lo;
    }

    int256 internal constant UNIT = 1e18;
    int256 internal constant PI = 3_141592653589793238;
    int256 internal constant TWO_PI = 6_283185307179586476;
    int256 internal constant PI_OVER_TWO = 1_570796326794896619;
    int256 internal constant PI_OVER_FOUR = 785398163397448309;
    int256 internal constant ATAN_A = 244_700_000_000_000_000;
    int256 internal constant ATAN_B = 66_300_000_000_000_000;
    int256 internal constant MAX_ACCURATE_ANGLE = 1e28;

    error ComplexDivisionByZero();
    error ComplexAngleOutOfBounds(int256 theta);
    error ComplexAtanInputOutOfBounds(int256 x);
    error ComplexOverflow();

    /// @notice Creates a complex number from its components.
    function complex(SD59x18 re, SD59x18 im) internal pure returns (Complex memory) {
        return Complex({ re: re, im: im });
    }

    /// @notice Returns the real and imaginary components.
    function components(Complex memory value) internal pure returns (SD59x18 re, SD59x18 im) {
        return (value.re, value.im);
    }

    /// @notice Adds two complex numbers.
    function add(Complex memory a, Complex memory b) internal pure returns (Complex memory) {
        return Complex({ re: a.re + b.re, im: a.im + b.im });
    }

    /// @notice Subtracts `b` from `a`.
    function sub(Complex memory a, Complex memory b) internal pure returns (Complex memory) {
        return Complex({ re: a.re - b.re, im: a.im - b.im });
    }

    /// @notice Returns the additive inverse of `value`.
    function neg(Complex memory value) internal pure returns (Complex memory) {
        return Complex({ re: -value.re, im: -value.im });
    }

    /// @notice Returns the complex conjugate.
    function conjugate(Complex memory value) internal pure returns (Complex memory) {
        return Complex({ re: value.re, im: -value.im });
    }

    /// @notice Multiplies two complex numbers.
    function mul(Complex memory a, Complex memory b) internal pure returns (Complex memory) {
        SD59x18 ac = a.re * b.re;
        SD59x18 bd = a.im * b.im;
        return Complex({ re: ac - bd, im: (a.re * b.im) + (a.im * b.re) });
    }

    /// @notice Squares a complex number with three fixed-point multiplications instead of four.
    function square(Complex memory value) internal pure returns (Complex memory) {
        SD59x18 reSquared = value.re * value.re;
        SD59x18 imSquared = value.im * value.im;
        SD59x18 product = value.re * value.im;
        return Complex({ re: reSquared - imSquared, im: product + product });
    }

    /// @notice Divides `a` by `b` with exact wide intermediate products.
    /// @dev Signed numerators and the denominator are accumulated at 512-bit precision. A bounded long division then
    /// computes the fixed-point result without materializing `b.re² + b.im²` in SD59x18 or truncating a Smith ratio.
    function div(Complex memory a, Complex memory b) internal pure returns (Complex memory result) {
        int256 aRe = a.re.unwrap();
        int256 aIm = a.im.unwrap();
        int256 bRe = b.re.unwrap();
        int256 bIm = b.im.unwrap();
        if (bRe == 0 && bIm == 0) revert ComplexDivisionByZero();

        Uint512 memory denominator = _add512(_fullMul(_absRaw(bRe), _absRaw(bRe)), _fullMul(_absRaw(bIm), _absRaw(bIm)));
        Signed512 memory realNumerator = _combineProducts(_signedProduct(aRe, bRe), _signedProduct(aIm, bIm), false);
        Signed512 memory imaginaryNumerator = _combineProducts(_signedProduct(aIm, bRe), _signedProduct(aRe, bIm), true);

        result.re = sd(_divideSigned(realNumerator, denominator));
        result.im = sd(_divideSigned(imaginaryNumerator, denominator));
    }

    /// @notice Returns `re² + im²`.
    /// @dev This is cheaper than `magnitude` but can overflow for very large components.
    function normSquared(Complex memory value) internal pure returns (SD59x18) {
        return (value.re * value.re) + (value.im * value.im);
    }

    /// @notice Returns the Euclidean magnitude without first squaring the largest component.
    /// @dev Reverts when the mathematical radius does not fit SD59x18.
    function magnitude(Complex memory value) internal pure returns (SD59x18) {
        SD59x18 reAbs = value.re.abs();
        SD59x18 imAbs = value.im.abs();
        bool realIsLargest = reAbs >= imAbs;
        SD59x18 largest = realIsLargest ? reAbs : imAbs;
        if (largest.unwrap() == 0) return sd(0);

        SD59x18 smallest = realIsLargest ? imAbs : reAbs;
        SD59x18 ratio = smallest / largest;
        return largest * (sd(UNIT) + (ratio * ratio)).sqrt();
    }

    /// @notice Converts a complex number to `(magnitude, angle)` polar coordinates.
    /// @dev The angle lies in `[-pi, pi]`. The zero value has angle zero.
    function toPolar(Complex memory value) internal pure returns (SD59x18 radius, SD59x18 theta) {
        return (magnitude(value), atan2(value.im, value.re));
    }

    /// @notice Constructs `radius * (cos(theta) + i * sin(theta))`.
    /// @dev Signed angles up to `1e10` radians are reduced modulo `2*pi` before conversion. The bound prevents error in
    /// the 18-decimal representation of `2*pi` from accumulating beyond the documented trigonometric envelope.
    function fromPolar(SD59x18 radius, SD59x18 theta) internal pure returns (Complex memory) {
        if (radius.unwrap() == 0) return Complex({ re: sd(0), im: sd(0) });
        int256 thetaRaw = theta.unwrap();
        if (_absRaw(thetaRaw) > uint256(MAX_ACCURATE_ANGLE)) revert ComplexAngleOutOfBounds(thetaRaw);
        uint256 normalized = _normalizeAngle(thetaRaw);
        (int256 sine, int256 cosine) = Trigonometry.sinCos(normalized);
        return Complex({ re: radius * sd(cosine), im: radius * sd(sine) });
    }

    /// @notice Approximates `atan2(y, x)` with maximum polynomial error around 0.0015 radians.
    /// @dev Returns zero for `(0, 0)`, matching common numerical-library behavior.
    function atan2(SD59x18 y, SD59x18 x) internal pure returns (SD59x18) {
        int256 yRaw = y.unwrap();
        int256 xRaw = x.unwrap();
        if (yRaw == 0) return xRaw < 0 ? sd(PI) : sd(0);
        if (xRaw == 0) return yRaw > 0 ? sd(PI_OVER_TWO) : sd(-PI_OVER_TWO);

        SD59x18 angle;
        if (_absRaw(xRaw) >= _absRaw(yRaw)) {
            angle = atanUnit(sd(_mulDivSigned(yRaw, UNIT, xRaw)));
            if (xRaw < 0) angle = yRaw > 0 ? angle + sd(PI) : angle - sd(PI);
        } else {
            angle = (yRaw > 0 ? sd(PI_OVER_TWO) : sd(-PI_OVER_TWO)) - atanUnit(sd(_mulDivSigned(xRaw, UNIT, yRaw)));
        }
        return angle;
    }

    /// @notice Approximates `atan(x)` for `x` in `[-1, 1]`.
    function atanUnit(SD59x18 x) internal pure returns (SD59x18) {
        if (_absRaw(x.unwrap()) > uint256(UNIT)) revert ComplexAtanInputOutOfBounds(x.unwrap());
        SD59x18 absX = x.abs();
        return (sd(PI_OVER_FOUR) * x) - (x * (absX - sd(UNIT)) * (sd(ATAN_A) + (sd(ATAN_B) * absX)));
    }

    /// @notice Returns the principal natural logarithm `ln(|z|) + i*arg(z)`.
    function ln(Complex memory value) internal pure returns (Complex memory) {
        (SD59x18 radius, SD59x18 theta) = toPolar(value);
        return Complex({ re: radius.ln(), im: theta });
    }

    /// @notice Returns the principal square root, whose real component is non-negative.
    /// @dev Uses an overflow-safe average and the stable component formula. For inputs beyond PRBMath's native square
    /// root range, `_sqrtNonnegative` retains at least nine decimal places instead of reverting on an intermediate
    /// `value * UNIT` overflow.
    function sqrt(Complex memory value) internal pure returns (Complex memory result) {
        int256 reRaw = value.re.unwrap();
        int256 imRaw = value.im.unwrap();

        if (imRaw == 0) {
            if (reRaw >= 0) return Complex({ re: _sqrtNonnegative(value.re), im: sd(0) });
            return Complex({ re: sd(0), im: _sqrtNonnegativeRaw(_absRaw(reRaw)) });
        }

        SD59x18 radius = magnitude(value);
        SD59x18 component = _sqrtAverage(radius, value.re.abs());
        SD59x18 doubledComponent = component + component;
        if (reRaw >= 0) {
            result.re = component;
            result.im = value.im / doubledComponent;
        } else {
            result.re = value.im.abs() / doubledComponent;
            result.im = imRaw > 0 ? component : -component;
        }
    }

    /// @notice Returns `e^value`.
    /// @dev A nonzero result requires the imaginary component to be within the supported trigonometric angle domain.
    function exp(Complex memory value) internal pure returns (Complex memory) {
        return fromPolar(value.re.exp(), value.im);
    }

    /// @notice Raises `value` to a signed 59.18-decimal fixed-point exponent.
    /// @dev Uses the principal polar branch. Argument error is multiplied by the absolute exponent; prefer `powu` for
    /// unsigned integer powers.
    function pow(Complex memory value, SD59x18 exponent) internal pure returns (Complex memory) {
        int256 exponentRaw = exponent.unwrap();
        if (exponentRaw == 0) return Complex({ re: sd(UNIT), im: sd(0) });
        if (exponentRaw == UNIT) return value;

        if (value.re.unwrap() == 0 && value.im.unwrap() == 0) {
            if (exponentRaw < 0) revert ComplexDivisionByZero();
            return Complex({ re: sd(0), im: sd(0) });
        }

        (SD59x18 radius, SD59x18 theta) = toPolar(value);
        int256 reducedExponent = exponentRaw % (TWO_PI * UNIT);
        int256 reducedPhase = (sd(reducedExponent) * theta).unwrap() % TWO_PI;
        return fromPolar(radius.pow(exponent), sd(reducedPhase));
    }

    /// @notice Raises `value` to an unsigned integer exponent using exponentiation by squaring.
    /// @dev Prefer this overload for integer powers: it avoids logarithms and trigonometry.
    function powu(Complex memory value, uint256 exponent) internal pure returns (Complex memory result) {
        result = Complex({ re: sd(UNIT), im: sd(0) });
        bool resultIsOne = true;
        while (exponent != 0) {
            if (exponent & 1 != 0) {
                result = resultIsOne ? value : mul(result, value);
                resultIsOne = false;
            }
            exponent >>= 1;
            if (exponent != 0) value = square(value);
        }
    }

    function _normalizeAngle(int256 angle) private pure returns (uint256) {
        int256 normalized = angle % TWO_PI;
        if (normalized < 0) normalized += TWO_PI;
        return uint256(normalized);
    }

    function _sqrtAverage(SD59x18 x, SD59x18 y) private pure returns (SD59x18) {
        uint256 xRaw = uint256(x.unwrap());
        uint256 yRaw = uint256(y.unwrap());
        uint256 sum = xRaw + yRaw;
        uint256 halfUnit = uint256(UNIT / 2);
        if (sum <= type(uint256).max / halfUnit) {
            return sd(int256(sqrtUint(sum * halfUnit)));
        }

        uint256 averageRoundedUp = (xRaw >> 1) + (yRaw >> 1) + ((xRaw & 1) | (yRaw & 1));
        return _sqrtNonnegative(sd(int256(averageRoundedUp)));
    }

    function _sqrtNonnegative(SD59x18 value) private pure returns (SD59x18) {
        return _sqrtNonnegativeRaw(uint256(value.unwrap()));
    }

    function _sqrtNonnegativeRaw(uint256 valueRaw) private pure returns (SD59x18) {
        if (valueRaw <= uint256(type(int256).max / UNIT)) return sd(int256(valueRaw)).sqrt();

        uint256 integerRoot = sqrtUint(valueRaw);
        return sd(int256(integerRoot * 1e9));
    }

    function _mulDivSigned(int256 x, int256 y, int256 denominator) private pure returns (int256) {
        uint256 resultAbs = mulDiv(_absRaw(x), _absRaw(y), _absRaw(denominator));
        bool resultIsNegative = ((x < 0) != (y < 0)) != (denominator < 0);
        return _fromSignedMagnitude(resultAbs, resultIsNegative);
    }

    function _divideSigned(Signed512 memory numerator, Uint512 memory denominator) private pure returns (int256) {
        uint256 quotient = _divScaled(numerator.magnitude, denominator);
        return _fromSignedMagnitude(quotient, numerator.negative);
    }

    function _divScaled(Uint512 memory numerator, Uint512 memory denominator) private pure returns (uint256 quotient) {
        if (_isZero(numerator)) return 0;

        // This is the overwhelmingly common path and uses PRBMath's optimized 512-by-256 division.
        if (numerator.hi == 0 && denominator.hi == 0) {
            return mulDiv(numerator.lo, uint256(UNIT), denominator.lo);
        }

        Uint768 memory dividend = _scale512(numerator, uint256(UNIT));
        uint256 dividendBits = _bitLength(dividend);
        uint256 denominatorBits = _bitLength(denominator);
        if (dividendBits < denominatorBits) return 0;

        uint256 bit = dividendBits - denominatorBits;
        if (bit > 256) revert ComplexOverflow();
        Uint768 memory shiftedDenominator = _shiftLeft(denominator, bit);

        while (true) {
            if (_gte(dividend, shiftedDenominator)) {
                if (bit == 256) revert ComplexOverflow();
                dividend = _sub768(dividend, shiftedDenominator);
                quotient |= uint256(1) << bit;
            }
            if (bit == 0) break;
            shiftedDenominator = _shiftRightOne(shiftedDenominator);
            unchecked {
                --bit;
            }
        }
    }

    function _signedProduct(int256 x, int256 y) private pure returns (Signed512 memory result) {
        result.magnitude = _fullMul(_absRaw(x), _absRaw(y));
        result.negative = !_isZero(result.magnitude) && ((x < 0) != (y < 0));
    }

    function _combineProducts(Signed512 memory x, Signed512 memory y, bool subtractY)
        private
        pure
        returns (Signed512 memory result)
    {
        bool yNegative = !_isZero(y.magnitude) && (y.negative != subtractY);
        if (_isZero(x.magnitude)) return Signed512({ magnitude: y.magnitude, negative: yNegative });
        if (_isZero(y.magnitude)) return x;

        if (x.negative == yNegative) {
            return Signed512({ magnitude: _add512(x.magnitude, y.magnitude), negative: x.negative });
        }
        if (_gte512(x.magnitude, y.magnitude)) {
            return Signed512({ magnitude: _sub512(x.magnitude, y.magnitude), negative: x.negative });
        }
        return Signed512({ magnitude: _sub512(y.magnitude, x.magnitude), negative: yNegative });
    }

    function _fullMul(uint256 x, uint256 y) private pure returns (Uint512 memory result) {
        assembly ("memory-safe") {
            let mm := mulmod(x, y, not(0))
            let lo := mul(x, y)
            mstore(result, sub(sub(mm, lo), lt(mm, lo)))
            mstore(add(result, 0x20), lo)
        }
    }

    function _add512(Uint512 memory x, Uint512 memory y) private pure returns (Uint512 memory result) {
        unchecked {
            result.lo = x.lo + y.lo;
            uint256 carry = result.lo < x.lo ? 1 : 0;
            result.hi = x.hi + y.hi;
            if (result.hi < x.hi) revert ComplexOverflow();
            uint256 highWithCarry = result.hi + carry;
            if (highWithCarry < result.hi) revert ComplexOverflow();
            result.hi = highWithCarry;
        }
    }

    function _sub512(Uint512 memory x, Uint512 memory y) private pure returns (Uint512 memory result) {
        unchecked {
            result.lo = x.lo - y.lo;
            result.hi = x.hi - y.hi - (x.lo < y.lo ? 1 : 0);
        }
    }

    function _scale512(Uint512 memory value, uint256 scalar) private pure returns (Uint768 memory result) {
        Uint512 memory lowProduct = _fullMul(value.lo, scalar);
        Uint512 memory highProduct = _fullMul(value.hi, scalar);
        unchecked {
            result.lo = lowProduct.lo;
            result.mid = lowProduct.hi + highProduct.lo;
            uint256 carry = result.mid < lowProduct.hi ? 1 : 0;
            result.hi = highProduct.hi + carry;
            if (result.hi < highProduct.hi) revert ComplexOverflow();
        }
    }

    function _shiftLeft(Uint512 memory value, uint256 shift) private pure returns (Uint768 memory result) {
        if (shift == 0) return Uint768({ hi: 0, mid: value.hi, lo: value.lo });
        if (shift == 256) return Uint768({ hi: value.hi, mid: value.lo, lo: 0 });

        result.lo = value.lo << shift;
        result.mid = (value.hi << shift) | (value.lo >> (256 - shift));
        result.hi = value.hi >> (256 - shift);
    }

    function _shiftRightOne(Uint768 memory value) private pure returns (Uint768 memory result) {
        result.lo = (value.lo >> 1) | (value.mid << 255);
        result.mid = (value.mid >> 1) | (value.hi << 255);
        result.hi = value.hi >> 1;
    }

    function _sub768(Uint768 memory x, Uint768 memory y) private pure returns (Uint768 memory result) {
        unchecked {
            result.lo = x.lo - y.lo;
            uint256 lowBorrow = x.lo < y.lo ? 1 : 0;
            result.mid = x.mid - y.mid - lowBorrow;
            uint256 midBorrow = x.mid < y.mid || (lowBorrow == 1 && x.mid == y.mid) ? 1 : 0;
            result.hi = x.hi - y.hi - midBorrow;
        }
    }

    function _gte(Uint768 memory x, Uint768 memory y) private pure returns (bool) {
        if (x.hi != y.hi) return x.hi > y.hi;
        if (x.mid != y.mid) return x.mid > y.mid;
        return x.lo >= y.lo;
    }

    function _gte512(Uint512 memory x, Uint512 memory y) private pure returns (bool) {
        return x.hi > y.hi || (x.hi == y.hi && x.lo >= y.lo);
    }

    function _bitLength(Uint512 memory value) private pure returns (uint256) {
        if (value.hi != 0) return 257 + msb(value.hi);
        return value.lo == 0 ? 0 : 1 + msb(value.lo);
    }

    function _bitLength(Uint768 memory value) private pure returns (uint256) {
        if (value.hi != 0) return 513 + msb(value.hi);
        if (value.mid != 0) return 257 + msb(value.mid);
        return value.lo == 0 ? 0 : 1 + msb(value.lo);
    }

    function _isZero(Uint512 memory value) private pure returns (bool) {
        return value.hi == 0 && value.lo == 0;
    }

    function _fromSignedMagnitude(uint256 resultAbs, bool resultIsNegative) private pure returns (int256) {
        uint256 minMagnitude = uint256(1) << 255;

        if (resultIsNegative) {
            if (resultAbs > minMagnitude) revert ComplexOverflow();
            if (resultAbs == minMagnitude) return type(int256).min;
            return -int256(resultAbs);
        }
        if (resultAbs >= minMagnitude) revert ComplexOverflow();
        return int256(resultAbs);
    }

    function _absRaw(int256 value) private pure returns (uint256) {
        unchecked {
            return value < 0 ? uint256(-(value + 1)) + 1 : uint256(value);
        }
    }
}
