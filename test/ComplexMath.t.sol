// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import { SD59x18, sd } from "@prb/math/src/SD59x18.sol";

import { Complex, ComplexMath } from "../contracts/Complex.sol";

contract ComplexHarness {
    using ComplexMath for Complex;

    function add(Complex memory a, Complex memory b) external pure returns (Complex memory) {
        return a.add(b);
    }

    function sub(Complex memory a, Complex memory b) external pure returns (Complex memory) {
        return a.sub(b);
    }

    function mul(Complex memory a, Complex memory b) external pure returns (Complex memory) {
        return a.mul(b);
    }

    function square(Complex memory value) external pure returns (Complex memory) {
        return value.square();
    }

    function div(Complex memory a, Complex memory b) external pure returns (Complex memory) {
        return a.div(b);
    }

    function magnitude(Complex memory value) external pure returns (SD59x18) {
        return value.magnitude();
    }

    function toPolar(Complex memory value) external pure returns (SD59x18, SD59x18) {
        return value.toPolar();
    }

    function fromPolar(SD59x18 radius, SD59x18 theta) external pure returns (Complex memory) {
        return ComplexMath.fromPolar(radius, theta);
    }

    function atan2(SD59x18 y, SD59x18 x) external pure returns (SD59x18) {
        return ComplexMath.atan2(y, x);
    }

    function ln(Complex memory value) external pure returns (Complex memory) {
        return value.ln();
    }

    function sqrt(Complex memory value) external pure returns (Complex memory) {
        return value.sqrt();
    }

    function exp(Complex memory value) external pure returns (Complex memory) {
        return value.exp();
    }

    function pow(Complex memory value, SD59x18 exponent) external pure returns (Complex memory) {
        return value.pow(exponent);
    }

    function powu(Complex memory value, uint256 exponent) external pure returns (Complex memory) {
        return value.powu(exponent);
    }
}

contract ComplexMathTest {
    using ComplexMath for Complex;

    int256 private constant UNIT = 1e18;
    int256 private constant PI = 3_141592653589793238;
    int256 private constant HALF_PI = 1_570796326794896619;
    int256 private constant SQRT_TWO = 1_414213562373095049;
    int256 private constant ATAN_TOLERANCE = 1_600_000_000_000_000;
    int256 private constant TRIG_TOLERANCE = 1_000_000_000;

    ComplexHarness private harness;

    error ValuesDiffer(int256 actual, int256 expected, int256 tolerance);
    error ValuesNotEqual(bytes32 actual, bytes32 expected);
    error ExpectedFalse();

    function setUp() public {
        harness = new ComplexHarness();
    }

    function testAddSubtractAndConjugate() public pure {
        Complex memory a = _complex(-1e18, 2e18);
        Complex memory b = _complex(3e18, -4e18);

        _assertComplex(a.add(b), 2e18, -2e18, 0);
        _assertComplex(a.sub(b), -4e18, 6e18, 0);
        _assertComplex(a.conjugate(), -1e18, -2e18, 0);
        _assertComplex(a.neg(), 1e18, -2e18, 0);
    }

    function testMultiply() public pure {
        _assertComplex(_complex(-1e18, 2e18).mul(_complex(3e18, -4e18)), 5e18, 10e18, 0);
        _assertComplex(_complex(-1e18, 2e18).square(), -3e18, -4e18, 0);
    }

    function testDivisionRepairsDenominatorBug() public pure {
        _assertComplex(_complex(1e18, 2e18).div(_complex(3e18, 4e18)), 44e16, 8e16, 2);
    }

    function testDivisionByZeroUsesCustomError() public {
        (bool success, bytes memory returnData) =
            address(harness).call(abi.encodeCall(ComplexHarness.div, (_complex(1e18, 1e18), _complex(0, 0))));
        _assertFalse(success);
        bytes4 selector;
        assembly ("memory-safe") {
            selector := mload(add(returnData, 0x20))
        }
        _assertEq(bytes32(selector), bytes32(ComplexMath.ComplexDivisionByZero.selector));
    }

    function testMagnitudeAvoidsIntermediateSquareOverflow() public pure {
        Complex memory value = _complex(4e48, 3e48);
        _assertApprox(value.magnitude().unwrap(), 5e48, 1e30);
    }

    function testPolarAxesAndNegativeAngles() public pure {
        _assertComplex(ComplexMath.fromPolar(sd(2e18), sd(-HALF_PI)), 0, -2e18, TRIG_TOLERANCE);
        _assertComplex(ComplexMath.fromPolar(sd(2e18), sd(5 * HALF_PI)), 0, 2e18, TRIG_TOLERANCE);

        (SD59x18 radius, SD59x18 theta) = _complex(-1e18, 0).toPolar();
        _assertApprox(radius.unwrap(), 1e18, 2);
        _assertEq(theta.unwrap(), PI);
    }

    function testAtan2EveryQuadrantAndOrigin() public pure {
        _assertApprox(ComplexMath.atan2(sd(1e18), sd(1e18)).unwrap(), PI / 4, ATAN_TOLERANCE);
        _assertApprox(ComplexMath.atan2(sd(1e18), sd(-1e18)).unwrap(), (3 * PI) / 4, ATAN_TOLERANCE);
        _assertApprox(ComplexMath.atan2(sd(-1e18), sd(-1e18)).unwrap(), (-3 * PI) / 4, ATAN_TOLERANCE);
        _assertApprox(ComplexMath.atan2(sd(-1e18), sd(1e18)).unwrap(), -PI / 4, ATAN_TOLERANCE);
        _assertEq(ComplexMath.atan2(sd(0), sd(0)).unwrap(), 0);
    }

    function testSquareRootAcrossQuadrants() public pure {
        _assertComplex(_complex(3e18, 4e18).sqrt(), 2e18, 1e18, 2);
        _assertComplex(_complex(3e18, -4e18).sqrt(), 2e18, -1e18, 2);
        _assertComplex(_complex(-4e18, 0).sqrt(), 0, 2e18, 0);
        _assertComplex(_complex(0, 4e18).sqrt(), SQRT_TWO, SQRT_TWO, 2);
    }

    function testExponentialAndLogarithm() public pure {
        _assertComplex(_complex(0, PI).exp(), -1e18, 0, TRIG_TOLERANCE);

        Complex memory result = _complex(1e18, 1e18).ln();
        _assertApprox(result.re.unwrap(), 346_573_590_279_972_654, 20);
        _assertApprox(result.im.unwrap(), PI / 4, ATAN_TOLERANCE);
    }

    function testIntegerPowerAvoidsTranscendentals() public pure {
        Complex memory value = _complex(1e18, 1e18);
        _assertComplex(value.powu(0), 1e18, 0, 0);
        _assertComplex(value.powu(2), 0, 2e18, 0);
        _assertComplex(value.powu(5), -4e18, -4e18, 0);
    }

    function testFractionalPower() public pure {
        _assertComplex(_complex(0, 4e18).pow(sd(5e17)), SQRT_TWO, SQRT_TWO, 200_000_000_000);
    }

    function testFuzzAddThenSubtract(int64 ar, int64 ai, int64 br, int64 bi) public pure {
        Complex memory a = _complex(int256(ar) * 1e12, int256(ai) * 1e12);
        Complex memory b = _complex(int256(br) * 1e12, int256(bi) * 1e12);
        Complex memory roundTrip = a.add(b).sub(b);
        _assertComplex(roundTrip, a.re.unwrap(), a.im.unwrap(), 0);
    }

    function testFuzzMultiplyByOne(int96 re, int96 im) public pure {
        Complex memory value = _complex(int256(re), int256(im));
        _assertComplex(value.mul(_complex(1e18, 0)), int256(re), int256(im), 0);
    }

    function testFuzzSquareMatchesMultiply(int64 re, int64 im) public pure {
        Complex memory value = _complex(int256(re) * 1e9, int256(im) * 1e9);
        Complex memory optimized = value.square();
        Complex memory general = value.mul(value);
        _assertComplex(optimized, general.re.unwrap(), general.im.unwrap(), 0);
    }

    function testFuzzDivisionRoundTrip(int32 ar, int32 ai, int32 br, int32 bi) public pure {
        if (br == 0 && bi == 0) return;
        Complex memory a = _complex(int256(ar) * 1e18, int256(ai) * 1e18);
        Complex memory b = _complex(int256(br) * 1e18, int256(bi) * 1e18);
        Complex memory roundTrip = a.div(b).mul(b);
        _assertComplex(roundTrip, a.re.unwrap(), a.im.unwrap(), 10_000_000_000);
    }

    function testGasAdd() public view {
        harness.add(_complex(-1e18, 2e18), _complex(3e18, -4e18));
    }

    function testGasMultiply() public view {
        harness.mul(_complex(-1e18, 2e18), _complex(3e18, -4e18));
    }

    function testGasSquare() public view {
        harness.square(_complex(-1e18, 2e18));
    }

    function testGasDivide() public view {
        harness.div(_complex(1e18, 2e18), _complex(3e18, 4e18));
    }

    function testGasSquareRoot() public view {
        harness.sqrt(_complex(3e18, 4e18));
    }

    function testGasPowu() public view {
        harness.powu(_complex(1e18, 1e18), 5);
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

    function _assertEq(int256 actual, int256 expected) private pure {
        if (actual != expected) revert ValuesDiffer(actual, expected, 0);
    }

    function _assertEq(bytes32 actual, bytes32 expected) private pure {
        if (actual != expected) revert ValuesNotEqual(actual, expected);
    }

    function _assertFalse(bool value) private pure {
        if (value) revert ExpectedFalse();
    }
}
