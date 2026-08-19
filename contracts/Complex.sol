// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24 <0.9.0;

import { SD59x18, sd } from "@prb/math/src/SD59x18.sol";

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
    int256 internal constant UNIT = 1e18;
    int256 internal constant PI = 3_141592653589793238;
    int256 internal constant TWO_PI = 6_283185307179586476;
    int256 internal constant PI_OVER_TWO = 1_570796326794896619;
    int256 internal constant PI_OVER_FOUR = 785398163397448309;
    int256 internal constant ATAN_A = 244_700_000_000_000_000;
    int256 internal constant ATAN_B = 66_300_000_000_000_000;

    error ComplexDivisionByZero();

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

    /// @notice Divides `a` by `b` using Smith's overflow-resistant algorithm.
    /// @dev The ratio is bounded by one, avoiding the potentially overflowing `b.re² + b.im²` denominator.
    function div(Complex memory a, Complex memory b) internal pure returns (Complex memory result) {
        if (b.re.unwrap() == 0 && b.im.unwrap() == 0) revert ComplexDivisionByZero();

        if (b.re.abs() >= b.im.abs()) {
            SD59x18 ratio = b.im / b.re;
            SD59x18 denominator = b.re + (b.im * ratio);
            result.re = (a.re + (a.im * ratio)) / denominator;
            result.im = (a.im - (a.re * ratio)) / denominator;
        } else {
            SD59x18 ratio = b.re / b.im;
            SD59x18 denominator = b.im + (b.re * ratio);
            result.re = ((a.re * ratio) + a.im) / denominator;
            result.im = ((a.im * ratio) - a.re) / denominator;
        }
    }

    /// @notice Returns `re² + im²`.
    /// @dev This is cheaper than `magnitude` but can overflow for very large components.
    function normSquared(Complex memory value) internal pure returns (SD59x18) {
        return (value.re * value.re) + (value.im * value.im);
    }

    /// @notice Returns the Euclidean magnitude without first squaring the largest component.
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
    /// @dev Signed and arbitrarily large angles are reduced modulo `2*pi` before conversion.
    function fromPolar(SD59x18 radius, SD59x18 theta) internal pure returns (Complex memory) {
        uint256 normalized = _normalizeAngle(theta.unwrap());
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
        if (x.abs() >= y.abs()) {
            angle = atanUnit(y / x);
            if (xRaw < 0) angle = yRaw > 0 ? angle + sd(PI) : angle - sd(PI);
        } else {
            angle = (yRaw > 0 ? sd(PI_OVER_TWO) : sd(-PI_OVER_TWO)) - atanUnit(x / y);
        }
        return angle;
    }

    /// @notice Approximates `atan(x)` for `x` in `[-1, 1]`.
    function atanUnit(SD59x18 x) internal pure returns (SD59x18) {
        SD59x18 absX = x.abs();
        return (sd(PI_OVER_FOUR) * x) - (x * (absX - sd(UNIT)) * (sd(ATAN_A) + (sd(ATAN_B) * absX)));
    }

    /// @notice Returns the principal natural logarithm `ln(|z|) + i*arg(z)`.
    function ln(Complex memory value) internal pure returns (Complex memory) {
        (SD59x18 radius, SD59x18 theta) = toPolar(value);
        return Complex({ re: radius.ln(), im: theta });
    }

    /// @notice Returns the principal square root, whose real component is non-negative.
    function sqrt(Complex memory value) internal pure returns (Complex memory result) {
        int256 reRaw = value.re.unwrap();
        int256 imRaw = value.im.unwrap();

        if (imRaw == 0) {
            if (reRaw >= 0) return Complex({ re: value.re.sqrt(), im: sd(0) });
            return Complex({ re: sd(0), im: (-value.re).sqrt() });
        }

        SD59x18 radius = magnitude(value);
        result.re = ((radius + value.re) / sd(2e18)).sqrt();
        SD59x18 imaginaryMagnitude = ((radius - value.re) / sd(2e18)).sqrt();
        result.im = imRaw > 0 ? imaginaryMagnitude : -imaginaryMagnitude;
    }

    /// @notice Returns `e^value`.
    function exp(Complex memory value) internal pure returns (Complex memory) {
        return fromPolar(value.re.exp(), value.im);
    }

    /// @notice Raises `value` to a signed 59.18-decimal fixed-point exponent.
    function pow(Complex memory value, SD59x18 exponent) internal pure returns (Complex memory) {
        if (value.re.unwrap() == 0 && value.im.unwrap() == 0) {
            int256 exponentRaw = exponent.unwrap();
            if (exponentRaw < 0) revert ComplexDivisionByZero();
            if (exponentRaw == 0) return Complex({ re: sd(UNIT), im: sd(0) });
            return Complex({ re: sd(0), im: sd(0) });
        }

        (SD59x18 radius, SD59x18 theta) = toPolar(value);
        return fromPolar(radius.pow(exponent), exponent * theta);
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
}
