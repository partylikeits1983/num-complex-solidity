// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import { SD59x18, sd } from "@prb/math/src/SD59x18.sol";

import { Complex, ComplexMath } from "../contracts/Complex.sol";

contract ComplexInvariantTest {
    using ComplexMath for Complex;

    int256 private constant UNIT = 1e18;
    int256 private constant POLAR_RELATIVE_TOLERANCE = 2_000_000_000_000_000;

    error ValuesDiffer(int256 actual, int256 expected, int256 tolerance);

    function testFuzzConjugateIsAnInvolution(int96 re, int96 im) public pure {
        Complex memory value = _complex(int256(re), int256(im));
        Complex memory roundTrip = value.conjugate().conjugate();
        _assertComplex(roundTrip, int256(re), int256(im), 0);
    }

    function testFuzzConjugateDistributesOverMultiplication(int32 ar, int32 ai, int32 br, int32 bi) public pure {
        Complex memory a = _scaledComplex(ar, ai);
        Complex memory b = _scaledComplex(br, bi);
        Complex memory left = a.mul(b).conjugate();
        Complex memory right = a.conjugate().mul(b.conjugate());
        _assertComplex(left, right.re.unwrap(), right.im.unwrap(), 0);
    }

    function testFuzzNormSquaredMatchesConjugateProduct(int32 re, int32 im) public pure {
        Complex memory value = _scaledComplex(re, im);
        Complex memory product = value.mul(value.conjugate());
        _assertApprox(product.re.unwrap(), value.normSquared().unwrap(), 0);
        _assertApprox(product.im.unwrap(), 0, 0);
    }

    function testFuzzMagnitudeIsConjugateInvariant(int64 re, int64 im) public pure {
        Complex memory value = _complex(int256(re) * 1e9, int256(im) * 1e9);
        _assertApprox(value.magnitude().unwrap(), value.conjugate().magnitude().unwrap(), 0);
    }

    function testFuzzSquareRootSquaresBack(int32 re, int32 im) public pure {
        Complex memory value = _scaledComplex(re, im);
        Complex memory roundTrip = value.sqrt().square();
        _assertComplex(roundTrip, value.re.unwrap(), value.im.unwrap(), 12);
    }

    function testFuzzPolarRoundTrip(int32 re, int32 im) public pure {
        Complex memory value = _scaledComplex(re, im);
        (SD59x18 radius, SD59x18 theta) = value.toPolar();
        Complex memory roundTrip = ComplexMath.fromPolar(radius, theta);
        int256 tolerance = (radius.unwrap() * POLAR_RELATIVE_TOLERANCE) / UNIT + 4;
        _assertComplex(roundTrip, value.re.unwrap(), value.im.unwrap(), tolerance);
    }

    function testFuzzDivisionRoundTripAcrossScaledDomain(int24 ar, int24 ai, int24 br, int24 bi) public pure {
        if (br == 0 && bi == 0) return;
        Complex memory a = _complex(int256(ar) * 1e15, int256(ai) * 1e15);
        Complex memory b = _complex(int256(br) * 1e12, int256(bi) * 1e12);
        Complex memory roundTrip = a.div(b).mul(b);
        int256 largest = _abs(a.re.unwrap()) >= _abs(a.im.unwrap()) ? _abs(a.re.unwrap()) : _abs(a.im.unwrap());
        int256 tolerance = largest / 1e12 + 1e9;
        _assertComplex(roundTrip, a.re.unwrap(), a.im.unwrap(), tolerance);
    }

    function testFuzzIntegerPowersCompose(int8 re, int8 im, uint8 firstExponent, uint8 secondExponent) public pure {
        uint256 first = uint256(firstExponent % 4);
        uint256 second = uint256(secondExponent % 4);
        Complex memory value = _complex(int256(re) * UNIT, int256(im) * UNIT);
        Complex memory left = value.powu(first + second);
        Complex memory right = value.powu(first).mul(value.powu(second));
        _assertComplex(left, right.re.unwrap(), right.im.unwrap(), 0);
    }

    function _scaledComplex(int32 re, int32 im) private pure returns (Complex memory) {
        return _complex(int256(re) * 1e9, int256(im) * 1e9);
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

    function _abs(int256 value) private pure returns (int256) {
        return value < 0 ? -value : value;
    }
}
