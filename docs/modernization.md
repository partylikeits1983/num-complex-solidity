# Version 2 modernization

## Completed in version 2

- Replace the deployable, state-free helper contract with an internal library that can be inlined and dead-code removed.
- Upgrade to Solidity 0.8.36 and PRBMath 4.2.0; enable optimizer and IR compilation for the Prague EVM.
- Correct division, negative polar angles, square roots outside the first quadrant, and zero-axis `atan2` behavior.
- Reduce expensive transcendental work with a combined sine/cosine lookup, a polynomial `atan2`, Cartesian square root,
  and exponentiation by squaring for integer powers.
- Add a scaled magnitude algorithm and exact wide complex division without overflowing intermediate squares.
- Replace ineffective JavaScript assertions with Solidity unit, fuzz, custom-error, gas, and downstream-consumer tests.
- Remove unused dependencies, vendored legacy PRBMath, generated coverage output, conflicting lockfiles, and stale API docs.
- Check the complete trigonometric lookup and `atanUnit` domains against a reproducible high-precision oracle, publish
  conservative error envelopes, and test composite operations against generated vectors.
- Add bounded invariant tests for square roots, polar and division round trips, conjugates, norms, and integer powers.
- Commit stable gas benchmarks and enforce a three-percent regression threshold in CI.
- Complete and document an independent internal numerical/security review, including the resulting boundary fixes and
  residual production risks.
