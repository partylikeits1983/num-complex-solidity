// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Num_Complex} from "../src/Complex.sol";

import {SD59x18, sd} from "@prb/math/src/SD59x18.sol";

contract CounterTest is Test {
    Num_Complex public num_complex;

    function setUp() public {
        num_complex = new Num_Complex();
    }

    function test_add() public {
        Num_Complex.Complex memory a = Num_Complex.Complex({re: sd(1e18), im: sd(1e18)});
        Num_Complex.Complex memory b = Num_Complex.Complex({re: sd(1e18), im: sd(1e18)});

        Num_Complex.Complex memory result = num_complex.add(a, b);

        assertEq(result.re.unwrap(), int(2e18));
        assertEq(result.im.unwrap(), int(2e18));
    }

}
