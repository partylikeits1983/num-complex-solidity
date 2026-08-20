# Accuracy and supported domains

`SD59x18` stores signed values with 18 decimal places. Exact arithmetic may still revert when a result or required
intermediate cannot fit the underlying signed integer. Transcendental and polar operations add approximation error.

## Verified approximation envelopes

| Approximation | Supported domain | Conservative absolute error |
| --- | --- | ---: |
| `Trigonometry.sin`, `cos`, `sinCos` | angle from `0` through `1e10` radians | `4.82e-6` at unit amplitude |
| `ComplexMath.fromPolar` | signed angle with `|theta| <= 1e10` radians | `|radius| * 4.82e-6`, plus fixed-point rounding |
| `ComplexMath.atanUnit` | `|x| <= 1` | `0.00151` radians |
| `ComplexMath.atan2` | all component pairs; `(0, 0)` is defined as zero | `0.00151` radians |

The oracle generator checks all 256 lookup-table interpolation cells and their continuous error extrema. Its bound also
includes lookup quantization, the 30-bit cycle conversion, and worst-case range-reduction drift at the enforced angle
limit. It locates every derivative sign change of the `atanUnit` error on `[0, 1]`; odd symmetry covers `[-1, 0]`.

The generated Solidity vectors cover axes, quadrants, the measured worst `atan` ratio, maximum supported angles,
sub-wei square-root and division intermediates, signed extrema, high dynamic range, PRBMath exponential boundaries,
and non-table-aligned powers. These vectors exercise composite functions but are representative rather than an
exhaustive proof over every pair of 256-bit components.

## Composite-operation domains

- `magnitude` and `toPolar` require the mathematical radius to fit `SD59x18`. The scaled algorithm avoids squaring the
  largest component. Its tests use a mixed tolerance of four raw units plus `2e-18` relative error.
- `sqrt` returns the principal root and uses the stable component formula. Non-axis inputs require a representable
  radius. Above PRBMath's native square-root range, the extended path has less than `1e-9` absolute component
  granularity; relative error is much smaller for those large inputs.
- `ln` requires a nonzero input and a representable radius. Its phase inherits the `atan2` envelope.
- `exp` inherits PRBMath's real-input domain. Inputs below `-41.446531673892822322` underflow to zero, while inputs above
  `133.084258667509499440` revert. A nonzero result also requires `|im| <= 1e10` radians.
- `pow` uses the principal polar branch. Exponents zero and one are exact shortcuts. Otherwise phase error can grow by
  approximately `|exponent| * 0.00151` radians before periodic reduction. Use `powu` for unsigned integer exponents.
- `div` accumulates exact signed 512-bit products and performs the final scaled quotient against a 768-bit dividend.
  Representable components are rounded toward zero. Division by zero or an unrepresentable result reverts.
- `mul`, `square`, and `normSquared` use checked fixed-point operations and may revert even when cancellation would make
  a later mathematical result representable.

Angles above the documented bound are rejected instead of silently accumulating error from the 18-decimal `2*pi`
constant. A zero radius returns zero without inspecting its irrelevant phase.

## Reproducing the analysis

Run:

```sh
cargo run --locked --release --bin oracle
forge test
forge test --fuzz-runs 10000
```

The locked Rust oracle uses 320-bit `rug` real and complex arithmetic, recomputes the analytic envelopes, regenerates
65 high-precision vectors in memory, and fails if the committed Solidity fixture differs. Pass `-- --write` to update
the fixture after reviewing an intentional numerical change.
