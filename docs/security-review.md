# Independent internal numerical and security review

Date: 2026-08-20

This review was performed in an isolated review pass separate from implementation. It is an internal engineering
review, not a third-party audit or a production-readiness certification.

## Scope and threat model

The review covered `Complex.sol`, `Trigonometry.sol`, package boundaries, numerical tests, generated oracle vectors,
and CI/gas controls. The library is entirely `internal pure`: it has no storage, authorization, reentrancy, delegatecall,
or external-call surface. The relevant risks are incorrect values propagating into a consuming protocol, adversarial
inputs causing unexpected reverts, approximation error, and gas regressions.

## Findings and dispositions

| Severity | Finding | Disposition |
| --- | --- | --- |
| High | Smith division discarded small and sub-wei denominator contributions before the final quotient. | Replaced it with exact signed 512-bit product accumulation and a 768-by-512-bit scaled division; added exact high-dynamic-range and sub-wei oracle vectors. |
| High | Balanced maximum division overflowed intermediate sums, including mathematically representable quotients. | The wide division path retains the full products and supports tested maximum, minimum, and signed-cancellation boundaries. |
| High | Square root suffered cancellation near the real axis and inherited PRBMath's narrower square-root input range. | Switched to the stable component formula and added an extended-range integer-root path. |
| High | Reducing arbitrary angles with an 18-decimal `2*pi` accumulated unbounded phase error. | Enforced `|theta| <= 1e10` radians and included worst-case drift in the `4.82e-6` envelope. |
| Medium | `atan2` rejected `int256.min` components because signed absolute value is not representable. | Replaced signed absolute-value ratios with unsigned-magnitude 512-bit division. |
| Medium | `pow` could overflow before reducing phase and needlessly approximated exponents zero and one. | Reduced phase before conversion and added exact zero/one shortcuts. |
| Medium | `atanUnit` accepted values outside the polynomial's proven interval. | Added an explicit domain check and custom error. |
| Medium | The PR had no enforceable oracle, invariant, package, or gas-regression checks. | Added generated high-precision vectors, bounded fuzz invariants, clean-package compilation, and pinned CI. |

## Residual risks

- `magnitude`, `toPolar`, non-axis `sqrt`, and `ln` require a representable radius. For example, two individually valid
  near-maximum components can have a magnitude larger than `SD59x18` and therefore revert.
- Approximation error compounds across operations. In particular, `pow` phase error grows with the absolute exponent;
  integer callers should use `powu`.
- Direct multiplication, squaring, and squared norm can revert on intermediate overflow.
- Extended-range square root deliberately trades sub-`1e-9` absolute precision for access to the full positive raw axis.
- Compiler, optimizer, PRBMath, or lookup-table changes require regenerating oracle and gas baselines.

Consumers should use application-specific bounds and tolerances. An independent external numerical and smart-contract
audit remains necessary before value-bearing production use.
