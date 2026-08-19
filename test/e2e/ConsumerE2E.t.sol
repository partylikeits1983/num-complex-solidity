// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import { SD59x18, sd } from "@prb/math/src/SD59x18.sol";
import { Complex, ComplexMath } from "num-complex-solidity/contracts/Complex.sol";

/// @dev Example downstream contract. Its package-style import is part of the end-to-end test.
contract SignalProcessor {
    using ComplexMath for Complex;

    function rotateSquare(int256 re, int256 im, int256 angle)
        external
        pure
        returns (int256 resultRe, int256 resultIm, int256 magnitude, int256 phase)
    {
        Complex memory input = ComplexMath.complex(sd(re), sd(im));
        Complex memory rotation = ComplexMath.fromPolar(sd(1e18), sd(angle));
        Complex memory result = input.powu(2).mul(rotation);
        (SD59x18 radius, SD59x18 theta) = result.toPolar();
        return (result.re.unwrap(), result.im.unwrap(), radius.unwrap(), theta.unwrap());
    }
}

contract ConsumerE2ETest {
    int256 private constant HALF_PI = 1_570796326794896619;

    function testPackageImportAndDeployedConsumerFlow() public {
        SignalProcessor consumer = new SignalProcessor();

        // (1 + i)^2 = 2i; rotating by -pi/2 produces 2 + 0i.
        (int256 re, int256 im, int256 radius, int256 theta) = consumer.rotateSquare(1e18, 1e18, -HALF_PI);

        _assertApprox(re, 2e18, 2_000_000_000);
        _assertApprox(im, 0, 2_000_000_000);
        _assertApprox(radius, 2e18, 2_000_000_000);
        _assertApprox(theta, 0, 2_000_000_000);
    }

    function _assertApprox(int256 actual, int256 expected, int256 tolerance) private pure {
        int256 difference = actual >= expected ? actual - expected : expected - actual;
        require(difference <= tolerance, "values differ");
    }
}
