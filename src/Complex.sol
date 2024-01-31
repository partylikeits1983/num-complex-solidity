// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title num_complex_solidity
/// @dev COMPLEX MATH FUNCTIONS
/// @author Alexander John Lee
/// @notice Solidity contract offering basic complex number functionalility

import {SD59x18, sd} from "@prb/math/src/SD59x18.sol";
import "./Trigonometry.sol";

contract Num_Complex {
    /// @notice Complex Type
    /// @dev Elementary Type - unable to use Solidity custom types yet
    struct Complex {
        SD59x18 re;
        SD59x18 im;
    }

    /// @notice Complex Type Wrap
    /// @param re real part
    /// @param im imaginary part
    /// @return Complex type
    function wrap(SD59x18 re, SD59x18 im) public pure returns (Complex memory) {
        return Complex(re, im);
    }

    /// @notice Complex Type Unwrap
    /// @param a Complex Number
    /// @return real imaginary
    function unwrap(Complex memory a) public pure returns (SD59x18, SD59x18) {
        return (a.re, a.im);
    }

    /// @notice ADDITION
    /// @param a Complex Number
    /// @param b Complex Number
    /// @return Complex Number
    function add(Complex memory a, Complex memory b) public pure returns (Complex memory) {
        Complex memory result = Complex({re: a.re.add(b.re), im: a.im.add(b.im)});

        return result;
    }

    /// @notice SUBTRACTION
    /// @param a Complex number
    /// @param b Complex number
    /// @return Complex Number
    function sub(Complex memory a, Complex memory b) public pure returns (Complex memory) {
        Complex memory result = Complex({re: a.re.sub(b.re), im: a.im.sub(b.im)});

        return result;
    }

    /// @notice MULTIPLICATION
    /// @param a Complex number
    /// @param b Complex number
    /// @return Complex Number
    function mul(Complex memory a, Complex memory b) public pure returns (Complex memory) {
        SD59x18 _a = a.re * b.re;
        SD59x18 _b = a.im * b.im;
        SD59x18 _c = a.im * b.re;
        SD59x18 _d = a.re * b.im;

        Complex memory result = Complex({re: _a - _b, im: _c + _d});

        return result;
    }

    /// @notice DIVISION
    /// @param a Complex number
    /// @param b Complex number
    /// @return Complex Number
    function div(Complex memory a, Complex memory b) public pure returns (Complex memory) {
        SD59x18 numA = a.re * b.re + a.im * b.im;
        SD59x18 numB = a.im * b.re - a.re * b.im;
        SD59x18 den = sd(b.re.unwrap() ** 2 + b.im.unwrap());

        Complex memory result = Complex({re: numA.div(den), im: numB.div(den)});

        return result;
    }

    /// @notice CALCULATE HYPOTENUSE
    /// @dev r^2 = a^2 + b^2
    /// @param a a
    /// @param b b
    /// @return r r
    function r2(SD59x18 a, SD59x18 b) public pure returns (SD59x18) {
        a = a.mul(a);
        b = b.mul(b);

        return (a + b).abs().sqrt();
    }

    /// @notice CONVERT COMPLEX NUMBER TO POLAR COORDINATES
    /// @dev WARNING R2 FUNCTION ALWAYS RETURNS POSITIVE VALUES => ELSE{code} IS UNREACHABLE
    /// @dev // atan vs atan2
    /// @return r r
    /// @return T theta
    function toPolar(Complex memory a) public pure returns (SD59x18, SD59x18) {
        SD59x18 r = r2(a.re, a.im);
        SD59x18 T = p_atan2(a.im, a.re);

        return (r, T);
    }

    /// @notice CONVERT FROM POLAR TO COMPLEX
    /// @dev https://github.com/rust-num/num-complex/blob/3a89daa2c616154035dd27d706bf7938bcbf30a8/src/lib.rs#L182
    /// @param r r
    /// @param T theta
    /// @return a Complex number
    function fromPolar(SD59x18 r, SD59x18 T) public pure returns (Complex memory a) {
        // @dev check if T is negative
        if (T.unwrap() > 0) {
            a.re = (r * sd(Trigonometry.cos(uint256(T.unwrap()))));
            a.im = (r * sd(Trigonometry.sin(uint256(T.unwrap()))));
        } else {
            a.re = -(r * sd(Trigonometry.cos(uint256(-T.unwrap()))));
            a.im = -(r * sd(Trigonometry.sin(uint256(-T.unwrap()))));
        }

        return a;
    }

    /// @notice ATAN2(Y,X) FUNCTION (LESS PRECISE LESS GAS)
    /// @param y y
    /// @param x x
    /// @return T T
    function atan2(SD59x18 y, SD59x18 x) public pure returns (SD59x18 T) {
        SD59x18 c1 = sd(3141592653589793300 / 4);
        SD59x18 c2 = sd(3e18) * c1;
        SD59x18 abs_y = y.abs();

        if (x.unwrap() >= 0) {
            SD59x18 r = (x - abs_y) / (x + abs_y);
            T = (c1 - c1 * r);
        } else {
            SD59x18 r = (x + abs_y) / (abs_y - x);
            T = (c2 - c1 * r);
        }
        if (y.unwrap() < 0) {
            return -T;
        } else {
            return T;
        }
    }

    /// @notice ATAN2(Y,X) FUNCTION (MORE PRECISE MORE GAS)
    /// @param y y
    /// @param x x
    /// @return T T
    function p_atan2(SD59x18 y, SD59x18 x) public pure returns (SD59x18 T) {
        SD59x18 c1 = sd(3141592653589793300 / 4);
        SD59x18 c2 = sd(3e18) * c1;
        SD59x18 abs_y = y.abs();

        if (x.unwrap() >= 0) {
            SD59x18 r = (x - abs_y) / (x + abs_y);
            T = sd(1963e14) * r.pow(sd(3e18)) - (sd(9817e14) * r) + c1;
        } else {
            SD59x18 r = (x + abs_y) / (abs_y - x);
            T = sd(1963e14) * r.pow(sd(3e18)) - (sd(9817e14) * r) + c2;
        }
        if (y.unwrap() < 0) {
            return -T;
        } else {
            return T;
        }
    }

    /// @notice PRECISE ATAN2(Y,X) FROM range -1 to 1 (MORE PRECISE LESS GAS)
    /// @param x (y/x)
    /// @return T T
    function atan1to1(int256 x) public pure returns (int256) {
        int256 y = ((7.85e17 * x) / 1e18) - (((x * (x - 1e18)) / 1e18) * (2.447e17 + ((6.63e16 * x) / 1e18))) / 1e18;

        return y;
    }

    /// @notice COMPLEX NATURAL LOGARITHM
    /// @param a Complex number
    /// @return Complex Number
    function ln(Complex memory a) public pure returns (Complex memory) {
        (a.re, a.im) = toPolar(a);
        a.re = a.re.ln();

        return a;
    }

    /// @notice COMPLEX SQUARE ROOT
    /// @dev only works if 0 < re & im
    /// @param a Complex number
    /// @return Complex Number
    function sqrt(Complex memory a) public pure returns (Complex memory) {
        Complex memory result;

        // if imaginary is 0
        if (a.im.unwrap() == 0) {
            // if real is positive
            if (a.re.unwrap() > 0) {
                // simple positive real √r, and copy `im` for its sign
                result = Complex({re: a.re.sqrt(), im: sd(0)});
            } else {
                // if real is negative
                // √(r e^(iπ)) = √r e^(iπ/2) = i√r
                // √(r e^(-iπ)) = √r e^(-iπ/2) = -i√r
                SD59x18 sqrtVal = -a.re.sqrt();
                // if imaginary is positive
                if (a.im.unwrap() > 0) {
                    result = Complex({re: sd(0), im: sqrtVal});
                } else {
                    // if imaginary is negative
                    result = Complex({re: sd(0), im: -sqrtVal});
                }
            }
        } else if (a.re.unwrap() == 0) {
            // √(r e^(iπ/2)) = √r e^(iπ/4) = √(r/2) + i√(r/2)
            // √(r e^(-iπ/2)) = √r e^(-iπ/4) = √(r/2) - i√(r/2)
            SD59x18 sqrtPart = (a.im.abs() / sd(2e18)).sqrt();
            if (a.im.unwrap() > 0) {
                result = Complex({re: sqrtPart, im: sqrtPart});
            } else {
                result = Complex({re: sqrtPart, im: -sqrtPart});
            }
        } else {
            // formula: sqrt(r e^(it)) = sqrt(r) e^(it/2)
            (SD59x18 r, SD59x18 T) = toPolar(a);
            result = fromPolar(r.sqrt(), T.div(sd(2e18)));
        }

        return result;
    }

    /// @notice COMPLEX EXPONENTIAL
    /// @dev e^(a + bi) = e^a (cos(b) + i*sin(b))
    /// @param a Complex number
    /// @return Complex Number
    function exp(Complex memory a) public pure returns (Complex memory) {
        SD59x18 r = a.re.exp();
        Complex memory result = fromPolar(r, a.im);

        return result;
    }

    /// @notice COMPLEX POWER
    /// @dev using Demoivre's formula
    /// @dev overflow risk
    /// @param a Complex number
    /// @param n base 1e18
    /// @return Complex number
    function pow(Complex memory a, SD59x18 n) public pure returns (Complex memory) {
        (SD59x18 r, SD59x18 theta) = toPolar(a);

        // gas savings
        SD59x18 rTOn = r.pow(n);
        SD59x18 nTheta = n * theta;

        Complex memory result = Complex({
            re: rTOn * sd(Trigonometry.cos(uint256(nTheta.unwrap()))),
            im: rTOn * sd(Trigonometry.sin(uint256(nTheta.unwrap())))
        });

        return result;
    }
}
