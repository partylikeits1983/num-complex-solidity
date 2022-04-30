# num_complex_solidity

`Complex` numbers for Solidity.

This library is in development (i.e. not extensively tested for deployment on the Ethereum mainnet). Please feel free to make a pull request with added functionality. 

Version 1.0

| Functions | Description |Gas Estimation |
| ------ | ------ | ------ |
| add | (a+bi) + (a+bi) | |
| sub | (a+bi) - (a+bi) | |
| mul | (a+bi) * (a+bi)| |
| div | (a+bi) / (a+bi) | |
| complexEXP | e^(a+bi) | | 
| r2 | a^2 + b^2 = c^2| |
| fromPolar | z=r(cosθ+isinθ) | |
| toPolar | z=r(cosθ+isinθ) | |
| atan2 | tan^-1 | |
| p_atan2 | precise tan^-1 | |
| atan1to1 | tan^-1 from -1 to 1 | |
| complexSQRT | (a+bi)^(1/2) | |
| intEXP | (a+bi)^n | |
| complexPOW | when n<1 (a+bi)^n | | 
| normalizeAmount | x / 1e18| | 
| deNormalizeAmount | x * 1e18 | |
| gasTest | dev function| |



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



## Acknowledgements

Big thanks to the authors of the the mds1/solidity-trigonometry and prb/math repositories


## Sponsors

If you would like to support this repository please feel free to make a contribution to this address:
0x74d6E0f5bff59A2a6b3CDe43c26EcAaC31101722

All proceeds will go to the development of this repository. Any contribution is greatly appreciated.


## License

Licensed under either of

 * [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
 * [MIT license](http://opensource.org/licenses/MIT)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.