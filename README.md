# num_complex_solidity

`Complex` numbers for Solidity.

This library is in development. Please feel free to make a pull request with added functionality.

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


## Testing

```sh
npx hardhat test tests/math.test.js
```


## Documentation

[num_complex_solidity documentation](docs/index.md)


### complex

```solidity
struct complex {
  int256 re;
  int256 im;
}
```

### add

```solidity
function add(int256 re, int256 im, int256 re1, int256 im1) public pure returns (int256, int256)
```

ADDITION

| Name | Type | Description |
| ---- | ---- | ----------- |
| re | int256 | real 1 |
| im | int256 | imaginary 1 |
| re1 | int256 | real 2 |
| im1 | int256 | imaginary 2 |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | int256 | re real |
| [1] | int256 | im imaginary |

### sub

```solidity
function sub(int256 re, int256 im, int256 re1, int256 im1) public pure returns (int256, int256)
```

SUBTRACTION

| Name | Type | Description |
| ---- | ---- | ----------- |
| re | int256 | real 1 |
| im | int256 | imaginary 1 |
| re1 | int256 | real 2 |
| im1 | int256 | imaginary 2 |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | int256 | re real |
| [1] | int256 | im imaginary |

### mul

```solidity
function mul(int256 re, int256 im, int256 re1, int256 im1) public pure returns (int256, int256)
```

MULTIPLICATION

| Name | Type | Description |
| ---- | ---- | ----------- |
| re | int256 | real 1 |
| im | int256 | imaginary 1 |
| re1 | int256 | real 2 |
| im1 | int256 | imaginary 2 |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | int256 | re real |
| [1] | int256 | im imaginary |

### div

```solidity
function div(int256 re, int256 im, int256 re1, int256 im1) public pure returns (int256, int256)
```

DIVISION

| Name | Type | Description |
| ---- | ---- | ----------- |
| re | int256 | real 1 |
| im | int256 | imaginary 1 |
| re1 | int256 | real 2 |
| im1 | int256 | imaginary 2 |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | int256 | re real |
| [1] | int256 | im imaginary |

### r2

```solidity
function r2(int256 a, int256 b) public pure returns (int256)
```

CALCULATE HYPOTENUSE

_r^2 = a^2 + b^2_

| Name | Type | Description |
| ---- | ---- | ----------- |
| a | int256 | a |
| b | int256 | b |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | int256 | r r |

### toPolar

```solidity
function toPolar(int256 re, int256 im) public pure returns (int256, int256)
```

CONVERT COMPLEX NUMBER TO POLAR COORDINATES

_WARNING R2 FUNCTION ALWAYS RETURNS POSITIVE VALUES => ELSE{code} IS UNREACHABLE
// atan vs atan2_

| Name | Type | Description |
| ---- | ---- | ----------- |
| re | int256 | real part |
| im | int256 | imaginary part |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | int256 | r r |
| [1] | int256 | T theta |

### fromPolar

```solidity
function fromPolar(int256 r, int256 T) public pure returns (int256 re, int256 im)
```

CONVERT FROM POLAR TO COMPLEX

_https://github.com/rust-num/num-complex/blob/3a89daa2c616154035dd27d706bf7938bcbf30a8/src/lib.rs#L182_

| Name | Type | Description |
| ---- | ---- | ----------- |
| r | int256 | r |
| T | int256 | theta |

| Name | Type | Description |
| ---- | ---- | ----------- |
| re | int256 | real |
| im | int256 | imaginary |

### atan2

```solidity
function atan2(int256 y, int256 x) public pure returns (int256 T)
```

ATAN2(Y,X) FUNCTION (LESS PRECISE LESS GAS)

| Name | Type | Description |
| ---- | ---- | ----------- |
| y | int256 | y |
| x | int256 | x |

| Name | Type | Description |
| ---- | ---- | ----------- |
| T | int256 | T |

### p_atan2

```solidity
function p_atan2(int256 y, int256 x) public pure returns (int256 T)
```

ATAN2(Y,X) FUNCTION (MORE PRECISE MORE GAS)

| Name | Type | Description |
| ---- | ---- | ----------- |
| y | int256 | y |
| x | int256 | x |

| Name | Type | Description |
| ---- | ---- | ----------- |
| T | int256 | T |

### atan1to1

```solidity
function atan1to1(int256 x) public pure returns (int256)
```

PRECISE ATAN2(Y,X) FROM range -1 to 1 (MORE PRECISE LESS GAS)

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | (y/x) |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | int256 | T T |

### complexLN

```solidity
function complexLN(int256 re, int256 im) public pure returns (int256, int256)
```

COMPLEX NATURAL LOGARITHM

| Name | Type | Description |
| ---- | ---- | ----------- |
| re | int256 | real |
| im | int256 | imaginary |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | int256 | re real |
| [1] | int256 | im imaginary |

### complexSQRT

```solidity
function complexSQRT(int256 re, int256 im) public pure returns (int256, int256)
```

COMPLEX SQUARE ROOT

_only works if 0 < re & im_

| Name | Type | Description |
| ---- | ---- | ----------- |
| re | int256 | real |
| im | int256 | imaginary |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | int256 | re real |
| [1] | int256 | im imaginary |

### complexEXP

```solidity
function complexEXP(int256 re, int256 im) public pure returns (int256, int256)
```

COMPLEX EXPONENTIAL

_e^(a + bi) = e^a (cos(b) + i*sin(b))_

| Name | Type | Description |
| ---- | ---- | ----------- |
| re | int256 | re |
| im | int256 | im |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | int256 | re re |
| [1] | int256 | im im |

### complexPOW

```solidity
function complexPOW(int256 re, int256 im, int256 n) public pure returns (int256, int256)
```

COMPLEX POWER

_using Demoivre's formula
overflow risk_

| Name | Type | Description |
| ---- | ---- | ----------- |
| re | int256 | re |
| im | int256 | im |
| n | int256 | base 1e18 |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | int256 | re re |
| [1] | int256 | im im |


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
