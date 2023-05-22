# num_complex_solidity

`Complex` numbers for Solidity.

# Usage

Install via npm:

```sh
$ npm i num_complex_solidity
```

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@partylikeits1983/complex_sol/contracts/Num_Complex.sol";

contract model {
    Num_Complex Complex;

    Num_Complex.Complex a = Complex.wrap(0, 1e18);

    function test() public returns (Num_Complex.Complex memory) {

        Num_Complex.Complex memory result = Complex.ln(a);

        return result;
    }
}

```

Version 1.0

| Functions   | Description         | Gas Estimation |
| ----------- | ------------------- | -------------- |
| add         | (a+bi) + (a+bi)     | 698            |
| sub         | (a+bi) - (a+bi)     | 687            |
| mul         | (a+bi) \* (a+bi)    | 2212           |
| div         | (a+bi) / (a+bi)     | 4099           |
| r2          | a^2 + b^2 = c^2     | 2188           |
| fromPolar   | z=r(cosθ+isinθ)     | 2518           |
| toPolar     | z=r(cosθ+isinθ)     | 5506           |
| atan2       | tan^-1              | 2632           |
| p_atan2     | precise tan^-1      | 3442           |
| atan1to1    | tan^-1 from -1 to 1 | 2496           |
| sqrt        | (a+bi)^(1/2)        | 8812           |
| poq         | when n<1 (a+bi)^n   | 18182          |
| exp         | e^(a+bi)            | 4986           |


## Documentation

[num_complex_solidity documentation](docs/index.md)




## Testing

```sh
npx hardhat test tests/math.test.ts
```


### Acknowledgements

Big thanks to the authors of the the - [mds1/solidity-trigonometry](https://github.com/mds1/solidity-trigonometry) and the [prb-math](https://github.com/paulrberg/prb-math) repositories


### Sponsors

[Paul Berg](https://github.com/paulrberg)

### License

Licensed under either of

- [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
- [MIT license](http://opensource.org/licenses/MIT)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.
