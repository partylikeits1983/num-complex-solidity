# num_complex_solidity

`Complex` numbers for Solidity.

This library is in development (i.e. not extensively tested for deployment on the Ethereum mainnet). Please feel free to make a pull request with added functionality.

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
| complexSQRT | (a+bi)^(1/2)        | 8812           |
| complexPOW  | when n<1 (a+bi)^n   | 18182          |
| complexEXP  | e^(a+bi)            | 4986           |

# Usage

WIth npm:

```bash
$ npm i @partylikeits1983/complex_sol
```

```solidity
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "@partylikeits1983/complex_sol/contracts/Complex.sol";

contract model {

    function test(int re, int im) public returns (int,int) {

        (re,im) = Complex.complexLN(re,im);

        return (re,im);
    }

```

## Testing

```sh
npx hardhat test tests/math.test.js
```

## Acknowledgements

Big thanks to the authors of the the - [mds1/solidity-trigonometry](https://github.com/mds1/solidity-trigonometry) and the [prb-math](https://github.com/paulrberg/prb-math) repositories

## Sponsor this Repository

If you would like to support this repository please feel free to make a contribution to this address:
0x74d6E0f5bff59A2a6b3CDe43c26EcAaC31101722

All proceeds will go to the development of this repository. Any contribution is greatly appreciated.

## Sponsors

[Paul Berg](https://github.com/paulrberg)

## License

Licensed under either of

- [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
- [MIT license](http://opensource.org/licenses/MIT)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.
