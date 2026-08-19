# num-complex-solidity

Gas-conscious complex arithmetic for Solidity, built on PRBMath's signed 59.18-decimal fixed-point type.

Version 2 is a breaking modernization. `ComplexMath` is an internal library, so consumers no longer deploy or call a
state-free helper contract. The compiler inlines only the functions a consumer uses.

## Install

```sh
npm install num-complex-solidity @prb/math
```

Foundry users should make both packages resolvable from `node_modules`:

```text
@prb/math/=node_modules/@prb/math/
num-complex-solidity/=node_modules/num-complex-solidity/
```

## Usage

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import { SD59x18, sd } from "@prb/math/src/SD59x18.sol";
import { Complex, ComplexMath } from "num-complex-solidity/contracts/Complex.sol";

contract Example {
    using ComplexMath for Complex;

    function square(int256 re, int256 im) external pure returns (int256, int256) {
        Complex memory value = ComplexMath.complex(sd(re), sd(im));
        Complex memory result = value.powu(2);
        return (result.re.unwrap(), result.im.unwrap());
    }
}
```

Inputs and outputs use 18 decimals: `1e18` represents `1`, and `-25e17` represents `-2.5`.

## API

| Function | Meaning | Notes |
| --- | --- | --- |
| `complex`, `components` | construct/deconstruct | Explicit PRBMath types |
| `add`, `sub`, `neg`, `conjugate` | basic arithmetic | Exact unless checked arithmetic overflows |
| `mul`, `square`, `div` | product, optimized square, and quotient | Division uses an overflow-resistant scaled ratio |
| `normSquared` | `re² + im²` | Cheaper, but intermediate squares can overflow |
| `magnitude` | `sqrt(re² + im²)` | Scaled algorithm avoids squaring the largest component |
| `toPolar`, `fromPolar` | Cartesian/polar conversion | Signed angles are reduced modulo `2*pi` |
| `atan2`, `atanUnit` | argument approximations | About 0.0015 radians maximum polynomial error |
| `ln`, `sqrt`, `exp` | principal complex functions | `sqrt` works in every quadrant |
| `pow` | fixed-point exponent | Uses polar form; suitable for fractional exponents |
| `powu` | unsigned integer exponent | Exponentiation by squaring; prefer for integer powers |

All library functions are `internal pure`. A contract's deployed bytecode includes only the reachable implementation.
PRBMath custom errors are propagated for fixed-point domain and overflow failures. Complex division by zero uses
`ComplexMath.ComplexDivisionByZero`.

## Gas

The optimizer uses 1,000 runs and the IR pipeline. Representative Prague-EVM gas from the external test harness is:

| Operation | Gas |
| --- | ---: |
| `add` | 1,419 |
| `square` | 2,207 |
| `mul` | 2,912 |
| `div` | 4,052 |
| `sqrt` for `3 + 4i` | 6,455 |
| `powu(..., 5)` | 6,501 |

Run `npm run gas` to reproduce the report. These figures include ABI dispatch and vary with compiler, optimizer, inputs,
and the consuming contract. They should not be compared directly with the version 1 README's estimates, whose compiler
settings and measurement method were not recorded.

The main efficiency changes are inlining instead of an external helper call, a shared sine/cosine lookup, direct
Cartesian square root, polynomial multiplication instead of general-purpose `pow` inside `atan2`, and the `powu`
integer fast path.

## Version 1 migration

| Version 1 | Version 2 |
| --- | --- |
| Deploy `Num_Complex` | `using ComplexMath for Complex` |
| `Num_Complex.Complex` | file-level `Complex` |
| `wrap` / `unwrap` | `complex` / `components` |
| `r2` | `magnitude` (or `normSquared`) |
| `p_atan2` / `atan1to1` | `atan2` / `atanUnit` |
| `pow(value, sd(integer))` | `powu(value, integer)` |

Version 2 also fixes the version 1 division denominator, negative polar angles, negative-real square roots, and tests
that constructed assertions without executing them.

## Development

Install [Foundry](https://getfoundry.sh/) and Node.js 20 or newer, then run:

```sh
npm install
npm test
npm run test:fuzz
npm run fmt
npm run gas
```

The end-to-end test imports the repository through its package name and calls the inlined library from a deployed
consumer contract.

## Accuracy and security

This library uses fixed-point approximations and a lookup-table trigonometry implementation. Transcendental results are
not exact, and rounding compounds across chained operations. Check domain limits in PRBMath, use application-specific
tolerances, and obtain an independent audit before using the library in value-bearing production systems.

Licensed under the MIT License.
