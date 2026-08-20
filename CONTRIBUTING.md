# Contributing

Install Foundry 1.7.1 and Rust 1.97.1, then initialize the pinned PRBMath submodule:

```sh
git submodule update --init --recursive
```

Before opening a pull request, run:

```sh
forge fmt --check
cargo fmt --all -- --check
cargo clippy --locked --all-targets -- -D warnings
forge build --deny warnings
forge test
forge test --fuzz-runs 10000
cargo run --locked --release --bin oracle
forge test --match-path test/e2e/ConsumerE2E.t.sol
forge test --gas-report
forge snapshot --check --tolerance 3 --match-test '^testGas'
```

Changes to numerical methods should include representative examples, boundary cases, fuzz properties, an accuracy
comparison, and a gas comparison. Do not weaken an existing tolerance merely to make a regression pass; explain and
document any intentional accuracy tradeoff.
