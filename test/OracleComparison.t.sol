// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import { sd } from "@prb/math/src/SD59x18.sol";

import { Complex, ComplexMath } from "../contracts/Complex.sol";
import { OracleVectors } from "./fixtures/OracleVectors.sol";

contract OracleComparisonTest {
    using ComplexMath for Complex;

    int256 private constant TRIG_TOLERANCE = 4_820_000_000_000;
    int256 private constant ATAN_TOLERANCE = 1_510_000_000_000_000;

    error ValuesDiffer(int256 actual, int256 expected, int256 tolerance);

    function testPolarAgainstHighPrecisionOracle() public pure {
        for (uint256 index = 0; index < OracleVectors.polarCount(); index++) {
            (int256 angle, int256 expectedRe, int256 expectedIm) = OracleVectors.polar(index);
            _assertComplex(ComplexMath.fromPolar(sd(1e18), sd(angle)), expectedRe, expectedIm, TRIG_TOLERANCE);
        }
    }

    function testAtan2AgainstHighPrecisionOracle() public pure {
        for (uint256 index = 0; index < OracleVectors.atanCount(); index++) {
            (int256 y, int256 x, int256 expected) = OracleVectors.atan(index);
            _assertApprox(ComplexMath.atan2(sd(y), sd(x)).unwrap(), expected, ATAN_TOLERANCE);
        }
    }

    function testMagnitudeAgainstHighPrecisionOracle() public pure {
        for (uint256 index = 0; index < OracleVectors.magnitudeCount(); index++) {
            (int256 re, int256 im, int256 expected, int256 tolerance) = OracleVectors.magnitude(index);
            _assertApprox(_complex(re, im).magnitude().unwrap(), expected, tolerance);
        }
    }

    function testDivisionAgainstExactWideOracle() public pure {
        for (uint256 index = 0; index < OracleVectors.divisionCount(); index++) {
            (int256 aRe, int256 aIm, int256 bRe, int256 bIm, int256 expectedRe, int256 expectedIm) =
                OracleVectors.division(index);
            _assertComplex(_complex(aRe, aIm).div(_complex(bRe, bIm)), expectedRe, expectedIm, 0);
        }
    }

    function testSquareRootAgainstHighPrecisionOracle() public pure {
        for (uint256 index = 0; index < OracleVectors.sqrtCount(); index++) {
            (int256 re, int256 im, int256 expectedRe, int256 expectedIm, int256 tolerance) = OracleVectors.sqrt(index);
            _assertComplex(_complex(re, im).sqrt(), expectedRe, expectedIm, tolerance);
        }
    }

    function testLogAgainstHighPrecisionOracle() public pure {
        for (uint256 index = 0; index < OracleVectors.logCount(); index++) {
            (int256 re, int256 im, int256 expectedRe, int256 expectedIm, int256 reTolerance, int256 imTolerance) =
                OracleVectors.log(index);
            Complex memory result = _complex(re, im).ln();
            _assertApprox(result.re.unwrap(), expectedRe, reTolerance);
            _assertApprox(result.im.unwrap(), expectedIm, imTolerance);
        }
    }

    function testExpAgainstHighPrecisionOracle() public pure {
        for (uint256 index = 0; index < OracleVectors.expCount(); index++) {
            (int256 re, int256 im, int256 expectedRe, int256 expectedIm, int256 tolerance) = OracleVectors.exp(index);
            _assertComplex(_complex(re, im).exp(), expectedRe, expectedIm, tolerance);
        }
    }

    function testPowAgainstHighPrecisionOracle() public pure {
        for (uint256 index = 0; index < OracleVectors.powCount(); index++) {
            (int256 re, int256 im, int256 exponent, int256 expectedRe, int256 expectedIm, int256 tolerance) =
                OracleVectors.pow(index);
            _assertComplex(_complex(re, im).pow(sd(exponent)), expectedRe, expectedIm, tolerance);
        }
    }

    function _complex(int256 re, int256 im) private pure returns (Complex memory) {
        return ComplexMath.complex(sd(re), sd(im));
    }

    function _assertComplex(Complex memory actual, int256 expectedRe, int256 expectedIm, int256 tolerance)
        private
        pure
    {
        _assertApprox(actual.re.unwrap(), expectedRe, tolerance);
        _assertApprox(actual.im.unwrap(), expectedIm, tolerance);
    }

    function _assertApprox(int256 actual, int256 expected, int256 tolerance) private pure {
        int256 difference = actual >= expected ? actual - expected : expected - actual;
        if (difference > tolerance) revert ValuesDiffer(actual, expected, tolerance);
    }
}
