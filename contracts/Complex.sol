// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title num_complex_solidity
/// @dev COMPLEX MATH FUNCTIONS
/// @author Alexander John Lee
/// @notice Solidity contract offering basic complex number functionalility

import "contracts/dependencies/prb-math/PRBMathSD59x18.sol";
import "./Trigonometry.sol";

contract Num_Complex {
    using PRBMathSD59x18 for int256;


    /// @notice Complex Type
    /// @dev Unable to use Solidity custom types yet
    struct Complex {
        int re;
        int im;
    }


    /// @notice Complex Type Wrap
    /// @param re real part
    /// @param im imaginary part
    /// @return Complex type
    function wrap(int re, int im) public pure returns (Complex memory) {
        return Complex(re, im);
    }


    /// @notice Complex Type Unwrap
    /// @param a Complex Number
    /// @return real imaginary
    function unwrap(Complex memory a) public pure returns (int, int) {
        return (a.re, a.im);
    }


    /// @notice ADDITION
    /// @param a Complex Number
    /// @param b Complex Number
    /// @return Complex Number
    function add(Complex memory a, Complex memory b) public pure returns (Complex memory) {
        a.re += b.re;
        a.im += b.im;

        return a;
    }


    /// @notice SUBTRACTION
    /// @param a Complex number
    /// @param b Complex number
    /// @return Complex Number
    function sub(Complex memory a, Complex memory b) public pure returns (Complex memory) {
        a.re -= b.re;
        a.im -= b.im;

        return a;
    }


    /// @notice MULTIPLICATION
    /// @param a Complex number
    /// @param b Complex number
    /// @return Complex Number
    function mul(Complex memory a, Complex memory b) public pure returns (Complex memory) {
        int _a = a.re * b.re;
        int _b = a.im * b.im;
        int _c = a.im * b.re;
        int _d = a.re * b.im;

        a.re = _a - _b;
        a.im = _c + _d;

        a.re /= 1e18;
        a.im /= 1e18;

        return a;
    }


    /// @notice DIVISION
    /// @param a Complex number
    /// @param b Complex number
    /// @return Complex Number
    function div(Complex memory a, Complex memory b) public pure returns (Complex memory) {
        int numA = a.re * b.re + a.im * b.im;
        int den = b.re**2 + b.im**2;
        int numB = a.im * b.re - a.re * b.im;
        
        a.re = (numA * 1e18) / den;
        b.im = (numB * 1e18) / den;

        return a;
    }


    /// @notice CALCULATE HYPOTENUSE
    /// @dev r^2 = a^2 + b^2
    /// @param a a
    /// @param b b
    /// @return r r
    function r2(int a, int b) public pure returns (int) {
        a = a.mul(a);
        b = b.mul(b);
        return (a + b).sqrt();
    }


    /// @notice CONVERT COMPLEX NUMBER TO POLAR COORDINATES
    /// @dev WARNING R2 FUNCTION ALWAYS RETURNS POSITIVE VALUES => ELSE{code} IS UNREACHABLE
    /// @dev // atan vs atan2
    /// @return r r
    /// @return T theta
    function toPolar(Complex memory a) public pure returns (int, int) {
        int r = r2(a.re, a.im);
        //int BdivA = re / im;
        if (r > 0) {
            // im/re or re/im ??
            int T = p_atan2(a.im, a.re);
            return (r,T);
        } else {
            // !!! if r is negative !!!
            int T = p_atan2(a.im, a.re) + 180e18;
            return (r,T);
        }
    }


    /// @notice CONVERT FROM POLAR TO COMPLEX
    /// @dev https://github.com/rust-num/num-complex/blob/3a89daa2c616154035dd27d706bf7938bcbf30a8/src/lib.rs#L182
    /// @param r r
    /// @param T theta
    /// @return a Complex number
    function fromPolar(int r, int T) public pure returns (Complex memory a) {
        // @dev check if T is negative
        if (T > 0) {
            a.re = (r * Trigonometry.cos(uint(T))) / 1e18;
            a.im = (r * Trigonometry.sin(uint(T))) / 1e18;
        } else {
            a.re = (r * Trigonometry.cos(uint(T))) / 1e18;
            a.im = -(r * Trigonometry.sin(uint(T * -1))) / 1e18;
        }
    }


    /// @notice ATAN2(Y,X) FUNCTION (LESS PRECISE LESS GAS)
    /// @param y y
    /// @param x x 
    /// @return T T
    function atan2(int y, int x) public pure returns (int T) {
        int c1 = 3141592653589793300/4;
        int c2 = 3*c1;
        int abs_y = y.abs() + 1e8;

        if (x >= 0) {
            int r = (x - abs_y) * 1e18 / (x + abs_y);
            T = (c1 * 1e18 - c1 * r) / 1e18;
        } else {
            int r = (x + abs_y) * 1e18 / (abs_y - x);
            T = (c2 * 1e18 - c1 * r) / 1e18;
        }
        if (y < 0) {
            return -T;
        } else {
            return T;
        }
    }


    /// @notice ATAN2(Y,X) FUNCTION (MORE PRECISE MORE GAS)
    /// @param y y
    /// @param x x 
    /// @return T T
    function p_atan2(int y, int x) public pure returns (int T) {
        int c1 = 3141592653589793300/4;
        int c2 = 3*c1;
        int abs_y = y.abs() + 1e8;

        if (x >= 0) {
            int r = (x - abs_y) * 1e18 / (x + abs_y);
            T = (1963e14 * r**3) / 1e54 - (9817e14 * r) / 1e18 + c1;
        } else{
            int r = (x + abs_y) * 1e18 / (abs_y - x);
            T = (1963e14 * r**3) / 1e54 - (9817e14 * r) / 1e18 + c2;
        }
        if (y < 0) {
            return -T;
        } else {
            return T;
        }
    }


    /// @notice PRECISE ATAN2(Y,X) FROM range -1 to 1 (MORE PRECISE LESS GAS)
    /// @param x (y/x)
    /// @return T T
    function atan1to1(int x) public pure returns (int) {
        int y = ((7.85e17 * x) / 1e18) - (((x* (x - 1e18)) / 1e18) * (2.447e17 + ((6.63e16 * x)/1e18))) / 1e18;
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
        // if imaginary is 0 
        if (a.im == 0) {
            // if real is positive
            if (a.re > 0) {
                // simple positive real √r, and copy `im` for its sign
                a.re = a.re.sqrt();
            } else {  // if real is negative
                // √(r e^(iπ)) = √r e^(iπ/2) = i√r
                // √(r e^(-iπ)) = √r e^(-iπ/2) = -i√r
                // if real is negative
                a.im = -a.re.sqrt();
                // if imaginary is positive
                if (a.im > 0) {
                    a.re = 0;
                } else {
                    // if imaginary is negative
                    a.im = -a.im;
                }
            }
        } else if (a.re == 0) {
            // √(r e^(iπ/2)) = √r e^(iπ/4) = √(r/2) + i√(r/2)
            // √(r e^(-iπ/2)) = √r e^(-iπ/4) = √(r/2) - i√(r/2
            a.re = (a.im.abs() / 2).sqrt();
            if (a.re > 0) {
                a.im = a.re;
            } else {
                a.im = -a.re;
            }
        } else {
            // formula: sqrt(r e^(it)) = sqrt(r) e^(it/2)
            (int r, int T) = toPolar(a);
            a = fromPolar(r.sqrt(), T/2);
        }
        return a;
    }


    /// @notice COMPLEX EXPONENTIAL
    /// @dev e^(a + bi) = e^a (cos(b) + i*sin(b))
    /// @param a Complex number
    /// @return Complex Number
    function exp(Complex memory a) public pure returns (Complex memory) {
        int r = a.re.exp();
        a = fromPolar(r, a.im);

        return a;
    }


    /// @notice COMPLEX POWER
    /// @dev using Demoivre's formula
    /// @dev overflow risk 
    /// @param a Complex number
    /// @param n base 1e18
    /// @return Complex number
    function pow(Complex memory a, int n) public pure returns (Complex memory) {
        (int r, int theta) = toPolar(a);

        // gas savings
        int rTOn = r.pow(n);
        int nTheta = n * theta / 1e18;

        a.re = rTOn * Trigonometry.cos(uint(nTheta)) / 1e18;
        a.im = rTOn * Trigonometry.sin(uint(nTheta)) / 1e18;

        return a;
    }
}
