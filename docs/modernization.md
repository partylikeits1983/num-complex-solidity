# Modernization plan

## Completed in version 2

- Replace the deployable, state-free helper contract with an internal library that can be inlined and dead-code removed.
- Upgrade to Solidity 0.8.36 and PRBMath 4.2.0; enable optimizer and IR compilation for the Prague EVM.
- Correct division, negative polar angles, square roots outside the first quadrant, and zero-axis `atan2` behavior.
- Reduce expensive transcendental work with a combined sine/cosine lookup, a polynomial `atan2`, Cartesian square root,
  and exponentiation by squaring for integer powers.
- Add stable magnitude and division algorithms that avoid the most common intermediate-square overflow paths.
- Replace ineffective JavaScript assertions with Solidity unit, fuzz, custom-error, gas, and downstream-consumer tests.
- Remove unused dependencies, vendored legacy PRBMath, generated coverage output, conflicting lockfiles, and stale API docs.

## Follow-up roadmap

- Compare the approximations against a high-precision oracle over the full supported domain and publish error envelopes.
- Add invariant/property tests for `sqrt(z)^2`, polar round trips, conjugates, and division across bounded domains.
- Track gas snapshots in CI and require an explanation for statistically meaningful regressions.
- Add a separately named high-precision argument implementation if applications need tighter error than `atan2` offers.
- Consider an optional packed, reduced-range representation for storage-heavy applications; keep it separate from
  `SD59x18` so the default API does not silently lose range.
- Obtain an independent security and numerical-method review before claiming production readiness.
