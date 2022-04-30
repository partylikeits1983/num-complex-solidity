pragma solidity ^0.8.12;

/// @title num_complex_solidity
/// @author Alexander John Lee
/// @notice Solidity library offering basic complex number functions where inputs and outputs are
/// signed integers. 

/// Huge thanks to the authors of the the mds1/solidity-trigonometry and prb/math repositories

import "@prb/math/contracts/PRBMathSD59x18.sol";
import "./Trigonometry.sol";

library Complex {
    using PRBMathSD59x18 for int256;

    // @dev COMPLEX MATH FUNCTIONS WITH 2 z INPUTS

    // @dev ADDITION
    function add(int re, int im, int re1, int im1) public pure returns (int,int) {
        re += re1;
        im += im1;

        return (re,im);
    }

    // @dev SUBTRACTION
    function sub(int re, int im, int re1, int im1) public pure returns (int,int) {
        re -= re1;
        im -= im1;

        return (re,im);
    }

    // @dev MULTIPLICATION
    function mul(int re, int im, int re1, int im1) public pure returns (int,int) {
        int a = re * re1;
        int b = im * im1;
        int c = im * re1;
        int d = re * im1;

        re = a-b;
        im = c+d;

        re /= 1e18;
        im /= 1e18;

        return (re,im);
    }

    // @dev DIVISION
    function div(int re, int im, int re1, int im1) public pure returns (int,int) {
        int numA = re * re1 + im * im1;
        int den = re1**2 + im1**2;
        int numB = im * re1 - re * im1;
        
        re = (numA * 1e18) / den;
        im = (numB * 1e18) / den;

        return (re,im);
    }

    // @dev COMPLEX EXPONENTIAL (STATUS: WORKING)
    // formula: e^(a + bi) = e^a (cos(b) + i*sin(b))
    function complexEXP(int re, int im) public pure returns (int,int) {
        int r = re.exp();
        (re, im) = fromPolar(r,im);

        return (re,im);
    }

    // @dev CALCULATE HYPOTENUSE (STATUS: WORKING)
    // r^2 = a^2 + b^2
    function r2(int a, int b) public pure returns (int) {
        a = (a*a) / 1e18;
        b = (b*b) / 1e18;
        return (a+b).sqrt();
    }

    // @dev CONVERT FROM POLAR TO COMPLEX (STATUS: WORKING)
    // https://github.com/rust-num/num-complex/blob/3a89daa2c616154035dd27d706bf7938bcbf30a8/src/lib.rs#L182
    function fromPolar(int r, int T) public pure returns (int re,int im) {
        // @dev check if T is negative
        if (T > 0) {
            re = (r * Trigonometry.cos(uint(T))) / 1e18;
            im = (r * Trigonometry.sin(uint(T))) / 1e18;
        }
        else {
            re = (r * Trigonometry.cos(uint(T))) / 1e18;
            // this specific line was a nightmare lol all good now though
            im = -(r * Trigonometry.sin(uint(T * -1))) / 1e18;
        }
    }

    // @dev CONVERT COMPLEX NUMBER TO POLAR COORDINATES (STATUS: WORKING)
    // @dev WARNING R2 FUNCTION ALWAYS RETURNS POSITIVE VALUES => ELSE{code} IS UNREACHABLE
    // atan vs atan2
    function toPolar(int re, int im) public pure returns (int,int) {
        int r = r2(re,im);
        //int BdivA = re / im;
        if (r > 0) {
            // im/re or re/im ??
            int T = p_atan2(im,re);
            return (r,T);
        }
        else {
            // !!! if r is negative !!!
            int T = p_atan2(im,re) + 180e18;
            return (r,T);
        }  
    }

    // @dev ATAN2(Y,X) FUNCTION (LESS PRECISE LESS GAS) (STATUS: WORKING)
    function atan2(int y, int x) public pure returns (int T) {
        int c1 = 3141592653589793300/4;
        int c2 = 3*c1;
        int abs_y = y.abs() + 1e8;

        if (x >= 0) {
            int r = (x - abs_y) * 1e18 / (x + abs_y);
            T = (c1 * 1e18 - c1 * r) / 1e18;
        } 
        else {
            int r = (x + abs_y) * 1e18 / (abs_y - x);
            T = (c2 * 1e18 - c1 * r) / 1e18;
        }
        if (y < 0) {
            return -T;
        }
        else {
            return T;
        }
    }

    // @dev ATAN2(Y,X) FUNCTION (MORE PRECISE MORE GAS) (STATUS: WORKING)
    function p_atan2(int y, int x) public pure returns (int T) {
        int c1 = 3141592653589793300/4;
        int c2 = 3*c1;
        int abs_y = y.abs() + 1e8;

        if (x >= 0) {
            int r = (x - abs_y) * 1e18 / (x + abs_y);
            T = (1963e14 * r**3) / 1e54 - (9817e14 * r) / 1e18 + c1;
        }
        else{
            int r = (x + abs_y) * 1e18 / (abs_y - x);
            T = (1963e14 * r**3) / 1e54 - (9817e14 * r) / 1e18 + c2;
        }
        if (y < 0) {
            return -T;
        }
        else {
            return T;
        }
    }

    // @dev PRECISE ATAN2(Y,X) FROM range -1 to 1 (STATUS: WORKING)
    function atan1to1(int x) public pure returns (int y) {
        int y = ((7.85e17 * x) / 1e18) - (((x*(x - 1e18)) / 1e18) * (2.447e17 + ((6.63e16*x)/1e18))) / 1e18;
        return y;
    }

    // @dev COMPLEX NATURAL LOGARITHM (STATUS: WORKING)
    function complexLN(int re, int im) public pure returns (int,int) {
        int T;

        (re, T) = toPolar(re,im);

        re = re.ln();
        im = T;

        return (re,im);
    }

    // @dev COMPLEX SQUARE ROOT (STATUS: if re & im > 0 WORKING) 
    function complexSQRT(int re, int im) public pure returns (int,int) {
        // if imaginary is 0 
        if (im == 0) {
            // if real is positive
            if (re > 0) {
                // simple positive real √r, and copy `im` for its sign
                re = re.sqrt();
            }
            // if real is negative
            else {
                // √(r e^(iπ)) = √r e^(iπ/2) = i√r
                // √(r e^(-iπ)) = √r e^(-iπ/2) = -i√r
                // if real is negative
                im = -re.sqrt();
                // if imaginary is positive
                if (im > 0) {
                    re = 0;
                }
                else {
                    // if imaginary is negative
                    im = -im;
                }
            }
        }
        else if (re == 0) {
            // √(r e^(iπ/2)) = √r e^(iπ/4) = √(r/2) + i√(r/2)
            // √(r e^(-iπ/2)) = √r e^(-iπ/4) = √(r/2) - i√(r/2
            re = (im.abs() / 2).sqrt();
            if (re > 0) {
                im = re;
            }
            else {
                im = -re;
            }
        }
        else {
            // formula: sqrt(r e^(it)) = sqrt(r) e^(it/2)
            (int r, int T) = toPolar(re,im);
            (re,im) = fromPolar(r.sqrt(), T/2);
        }
        return (re, im);
    }

    // @dev x^n
    // WARNING REQUIRES TESTING (STATUS: REQUIRES TESTING)
    function intEXP(int si, int sn) public pure returns(int) {
        // should change to certain precision i.e. 1e15 => (0.001)^n
        si /= 1e15;
        
        uint ui = uint(si);
        uint un = uint(sn);

        ui = ui**un;

        // convert back to 1e18 form
        ui *= 1e15;

        // convert back to signed integer type
        si = int(ui);

        return si;
    }

    /* PYTHON logic
    z = complex(-2,2)
    math.atan2(2,-2)
    r,theta = cmath.polar(z)
    n = 8
    re = r**n * (math.cos(n*theta))
    im = r**n * (math.sin(n*theta))
    */

    // IN PROGRESS!!
    // @dev COMPLEX POWER USING DEMOIVRE'S FORUMULA (STATUS: NEEDS CHECKING) - hint 1e18 
    // WARNING MUST ADD CHECKER OF MAX VALS FOR INPUT 

    /*
    function complexPOW(int re, int im, int n) public returns (int,int) {

        int r = r2(re, im);
        int theta = p_atan2(re, im);

        // gas savings
        int rTOn = r**n / 1e18;
        int nTheta = n * theta / 1e18;

        re= rTOn * Trigonometry.cos(nTheta);
        im = rTOn * Trigonometry.sin(nTheta);

        return (re,im);
    }
    */
    
    // @dev DIVIDE INPUT BY 1e18
    function normalizeAmount(int x) public pure returns (int) {
        x /= 1e18;
        return x;
    }

    // @dev MULTIPLY INPUT BY 1e18
    function deNormalizeAmount(int x) public pure returns (int) {
        x *= 1e18;
        return x;
    }

    // @dev GAS TEST IN LOOP TEST FUNCTION (not for production)
    function gasTest(int re, int im, int runs) public pure returns (int,int) {
        for (int i = 0; i < runs; i++) {
            (re,im) = complexLN(re,im);
        }
        return (re,im);
    }

    // @dev SQUARE ROOT FROM PRB LIBRARY TEST FUNCTIONS
    /// @dev Assuming x = 1e18 => returns 1e18
    function PRBsqrt(int256 x) public pure returns (int256 y) {
        y = x.sqrt();
        return y;
    }

    // @dev NATURAL LOGARITHM PRB LIBRARY
    function PRBln(int256 x) external pure returns (int256 result) {
        result = x.ln();
    }

    /* (DEPRECATED)
    // @dev ARCTANGENT HANDLER
    // @dev handle if abs(x) is greater than 1
    function atan(int x) public pure returns (int y) {
        if (x.abs() <= 1e18) {
            y = atan1to1(x);
        }
        else {
            y = atanLookup1toINF(x);
        }
        //return y;
    }
    // @dev abs(x) > 1 returns 1.5
    // @dev returns 1.5
    function atanLookup1toINF(int x) public  pure returns (int y) {
         return 15e17;
    }
    // @dev -1 TO 1 ARCTANGENT FUNCTION
    // @dev from 0 to 1 
    // needs abs(x) functionality 
    function atan1to1(int x) public pure returns (int y) {
        int y = ((7.85e17 * x) / 1e18) - (((x*(x - 1e18)) / 1e18) * (2.447e17 + ((6.63e16*x)/1e18))) / 1e18;
        return y;
    }
    */

        /*
    // @dev COMPLEX LOG (DEPRECATED)
    function complexLog(int re,int im) public pure returns (int,int) {
        
        /// Returns the logarithm of z with respect to an arbitrary base.
        // formula: log_y(x) = log_y(ρ e^(i θ))
        // = log_y(ρ) + log_y(e^(i θ)) = log_y(ρ) + ln(e^(i θ)) / ln(y)
        // = log_y(ρ) + i θ / ln(y)
        /*
        #[inline]
        pub fn log(self, base: T) -> Self {
            let (r, theta) = self.to_polar();
            Self::new(r.log(base), theta / base.ln())
        }
        
        (int re, int T) = toPolar(re,im);
        re = re.ln();
        return (re, im);
    }
    */

}