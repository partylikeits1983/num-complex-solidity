// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/Complex.sol";
import "src/Trigonometry.sol";


contract ContractTest is Test { 

    function testadd() public pure {
        Complex.add(1e18,1e18,1e18,1e18);
    }
    
    function testsub() public pure {
        Complex.sub(1e18,1e18,1e18,1e18);
    }

    function testmul() public pure {
        Complex.mul(1e18,1e18,1e18,1e18);
    }

    function testdiv() public pure {
        Complex.div(1e18,1e18,1e18,1e18);
    }

    function testr2() public pure {
        Complex.r2(1e18,1e18);
    }

    function testtoPolar() public pure {
        Complex.toPolar(1e18,1e18);
    }

    function testfromPolar() public pure {
        Complex.fromPolar(1e18,1e18);
    }

    function testatan2() public pure {
        Complex.atan2(1e18,1e18);
    }

    function testp_atan2() public pure {
        Complex.p_atan2(1e18,1e18);
    }

    function testatan1to1() public pure {
        Complex.atan1to1(5e17);
    }

    function testcomplexLN() public pure {
        Complex.complexLN(1e18,1e18);
    }

    function testcomplexSQRT() public pure {
        Complex.complexSQRT(1e18,1e18);
    }

    function testcomplexEXP() public pure {
        Complex.complexEXP(1e18,1e18);
    }

    function testcomplexPOW() public pure {
        Complex.complexPOW(1e18,1e18,2);
    }

    function testsin() public pure {
        Trigonometry.sin(1e18);
    }

    function testcos() public pure {
        Trigonometry.cos(1e18);
    }
}