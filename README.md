# num-complex-solidity

Gas-conscious complex arithmetic for Solidity, built on PRBMath's signed 59.18-decimal fixed-point type.

`ComplexMath` is an internal library, so consumers do not deploy a helper contract. The compiler inlines only the
functions a consumer uses.

## Install

Foundry consumers can install both pinned source dependencies:

```sh
forge install num-complex-solidity=partylikeits1983/num-complex-solidity prb-math=PaulRBerg/prb-math@v4.2.0
```

Add these remappings:

```text
@prb/math/=lib/prb-math/
num_complex_solidity/=lib/num-complex-solidity/
```

Consumers that resolve Solidity packages through `node_modules` can install from npm:

```sh
npm install num_complex_solidity @prb/math
```

For that installation method, use:

```text
@prb/math/=node_modules/@prb/math/
num_complex_solidity/=node_modules/num_complex_solidity/
```

## Usage

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import { SD59x18, sd } from "@prb/math/src/SD59x18.sol";
import { Complex, ComplexMath } from "num_complex_solidity/contracts/Complex.sol";

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
| `mul`, `square`, `div` | product, optimized square, and quotient | Division uses exact 512-bit products and a 768-bit scaled dividend |
| `normSquared` | `re² + im²` | Cheaper, but intermediate squares can overflow |
| `magnitude` | `sqrt(re² + im²)` | Scaled algorithm avoids squaring the largest component |
| `toPolar`, `fromPolar` | Cartesian/polar conversion | Signed angles up to `1e10` radians are reduced modulo `2*pi` |
| `atan2`, `atanUnit` | argument approximations | At most 0.00151 radians polynomial error |
| `ln`, `sqrt`, `exp` | principal complex functions | `sqrt` uses stable components in every quadrant |
| `pow` | fixed-point exponent | Principal real power; phase error grows with the exponent |
| `powu` | unsigned integer exponent | Exponentiation by squaring; prefer for integer powers |

All library functions are `internal pure`. A contract's deployed bytecode includes only the reachable implementation.
PRBMath custom errors are propagated for fixed-point domain and overflow failures. Complex division by zero uses
`ComplexMath.ComplexDivisionByZero`.

## Accuracy and supported domains

`SD59x18` stores signed values with 18 decimal places. Exact arithmetic can revert when a result or required
intermediate does not fit the underlying signed integer. Transcendental and polar operations add approximation error.

| Approximation | Supported domain | Conservative absolute error |
| --- | --- | ---: |
| `Trigonometry.sin`, `cos`, `sinCos` | angle from `0` through `1e10` radians | `4.82e-6` at unit amplitude |
| `ComplexMath.fromPolar` | signed angle with `|theta| <= 1e10` radians | `|radius| * 4.82e-6`, plus rounding |
| `ComplexMath.atanUnit` | `|x| <= 1` | `0.00151` radians |
| `ComplexMath.atan2` | all component pairs; `(0, 0)` returns zero | `0.00151` radians |

Composite-operation constraints:

- `magnitude` and `toPolar` require the mathematical radius to fit `SD59x18`.
- Non-axis `sqrt` inputs require a representable radius. The extended-range path has less than `1e-9` absolute
  component granularity above PRBMath's native square-root range.
- `ln` requires a nonzero input and a representable radius.
- `exp` underflows to zero below `-41.446531673892822322` and reverts above `133.084258667509499440`. A nonzero result
  also requires `|im| <= 1e10` radians.
- `pow` uses the principal polar branch, so phase error can grow by approximately `|exponent| * 0.00151` radians. Use
  `powu` for unsigned integer exponents.
- `div` rounds representable components toward zero and reverts for division by zero or an unrepresentable result.
- `mul`, `square`, and `normSquared` can revert on checked intermediate overflow.

Angles above the documented bound are rejected. A zero radius returns zero without inspecting its irrelevant phase.

## Gas

The optimizer uses 1,000 runs and the IR pipeline. Representative Prague-EVM gas from the external test harness is:

| Operation | Gas |
| --- | ---: |
| `add` | 1,419 |
| `square` | 2,207 |
| `mul` | 2,912 |
| `div` | 8,435 |
| `sqrt` for `3 + 4i` | 5,224 |
| `powu(..., 5)` | 6,501 |

Run `forge test --gas-report` to reproduce the report. These figures include ABI dispatch and vary with compiler,
optimizer, inputs, and the consuming contract.

## Development

Install Foundry 1.7.1 and Rust. The repository pins Rust 1.97.1 and PRBMath v4.2.0. Initialize the dependency
submodule, then run:

```sh
git submodule update --init --recursive
forge build --deny warnings
forge test
forge test --fuzz-runs 10000
cargo run --locked --release --bin oracle
forge test --match-path test/e2e/ConsumerE2E.t.sol
forge test --gas-report
forge snapshot --check --tolerance 3 --match-test '^testGas'
```

Foundry owns contract formatting, builds, tests, fuzzing, the package-style consumer test, and gas snapshots. The only
non-Solidity tool is the locked Rust oracle, which uses 320-bit `rug` complex arithmetic to regenerate and verify the
committed comparison vectors. Node.js is not required for development or CI; `package.json` provides npm publication
metadata.

Licensed under the MIT License.
