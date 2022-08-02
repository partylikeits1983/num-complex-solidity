# Solidity API

## Complex

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

## Trigonometry

Solidity library offering basic trigonometry functions where inputs and outputs are
integers. Inputs are specified in radians scaled by 1e18, and similarly outputs are scaled by 1e18.

This implementation is based off the Solidity trigonometry library written by Lefteris Karapetsas
which can be found here: https://github.com/Sikorkaio/sikorka/blob/e75c91925c914beaedf4841c0336a806f2b5f66d/contracts/trigonometry.sol

Compared to Lefteris' implementation, this version makes the following changes:
  - Uses a 32 bits instead of 16 bits for improved accuracy
  - Updated for Solidity 0.8.x
  - Various gas optimizations
  - Change inputs/outputs to standard trig format (scaled by 1e18) instead of requiring the
    integer format used by the algorithm

Lefertis' implementation is based off Dave Dribin's trigint C library
    http://www.dribin.org/dave/trigint/

Which in turn is based from a now deleted article which can be found in the Wayback Machine:
    http://web.archive.org/web/20120301144605/http://www.dattalo.com/technical/software/pic/picsine.html

### INDEX_WIDTH

```solidity
uint256 INDEX_WIDTH
```

### INTERP_WIDTH

```solidity
uint256 INTERP_WIDTH
```

### INDEX_OFFSET

```solidity
uint256 INDEX_OFFSET
```

### INTERP_OFFSET

```solidity
uint256 INTERP_OFFSET
```

### ANGLES_IN_CYCLE

```solidity
uint32 ANGLES_IN_CYCLE
```

### QUADRANT_HIGH_MASK

```solidity
uint32 QUADRANT_HIGH_MASK
```

### QUADRANT_LOW_MASK

```solidity
uint32 QUADRANT_LOW_MASK
```

### SINE_TABLE_SIZE

```solidity
uint256 SINE_TABLE_SIZE
```

### PI

```solidity
uint256 PI
```

### TWO_PI

```solidity
uint256 TWO_PI
```

### PI_OVER_TWO

```solidity
uint256 PI_OVER_TWO
```

### entry_bytes

```solidity
uint8 entry_bytes
```

### entry_mask

```solidity
uint256 entry_mask
```

### sin_table

```solidity
bytes sin_table
```

### sin

```solidity
function sin(uint256 _angle) internal pure returns (int256)
```

Return the sine of a value, specified in radians scaled by 1e18

_This algorithm for converting sine only uses integer values, and it works by dividing the
circle into 30 bit angles, i.e. there are 1,073,741,824 (2^30) angle units, instead of the
standard 360 degrees (2pi radians). From there, we get an output in range -2,147,483,647 to
2,147,483,647, (which is the max value of an int32) which is then converted back to the standard
range of -1 to 1, again scaled by 1e18_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _angle | uint256 | Angle to convert |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | int256 | Result scaled by 1e18 |

### cos

```solidity
function cos(uint256 _angle) internal pure returns (int256)
```

Return the cosine of a value, specified in radians scaled by 1e18

_This is identical to the sin() method, and just computes the value by delegating to the
sin() method using the identity cos(x) = sin(x + pi/2)
Overflow when `angle + PI_OVER_TWO > type(uint256).max` is ok, results are still accurate_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _angle | uint256 | Angle to convert |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | int256 | Result scaled by 1e18 |

## PRBMath__MulDivFixedPointOverflow

```solidity
error PRBMath__MulDivFixedPointOverflow(uint256 prod1)
```

Emitted when the result overflows uint256.

## PRBMath__MulDivOverflow

```solidity
error PRBMath__MulDivOverflow(uint256 prod1, uint256 denominator)
```

Emitted when the result overflows uint256.

## PRBMath__MulDivSignedInputTooSmall

```solidity
error PRBMath__MulDivSignedInputTooSmall()
```

Emitted when one of the inputs is type(int256).min.

## PRBMath__MulDivSignedOverflow

```solidity
error PRBMath__MulDivSignedOverflow(uint256 rAbs)
```

Emitted when the intermediary absolute result overflows int256.

## PRBMathSD59x18__AbsInputTooSmall

```solidity
error PRBMathSD59x18__AbsInputTooSmall()
```

Emitted when the input is MIN_SD59x18.

## PRBMathSD59x18__CeilOverflow

```solidity
error PRBMathSD59x18__CeilOverflow(int256 x)
```

Emitted when ceiling a number overflows SD59x18.

## PRBMathSD59x18__DivInputTooSmall

```solidity
error PRBMathSD59x18__DivInputTooSmall()
```

Emitted when one of the inputs is MIN_SD59x18.

## PRBMathSD59x18__DivOverflow

```solidity
error PRBMathSD59x18__DivOverflow(uint256 rAbs)
```

Emitted when one of the intermediary unsigned results overflows SD59x18.

## PRBMathSD59x18__ExpInputTooBig

```solidity
error PRBMathSD59x18__ExpInputTooBig(int256 x)
```

Emitted when the input is greater than 133.084258667509499441.

## PRBMathSD59x18__Exp2InputTooBig

```solidity
error PRBMathSD59x18__Exp2InputTooBig(int256 x)
```

Emitted when the input is greater than 192.

## PRBMathSD59x18__FloorUnderflow

```solidity
error PRBMathSD59x18__FloorUnderflow(int256 x)
```

Emitted when flooring a number underflows SD59x18.

## PRBMathSD59x18__FromIntOverflow

```solidity
error PRBMathSD59x18__FromIntOverflow(int256 x)
```

Emitted when converting a basic integer to the fixed-point format overflows SD59x18.

## PRBMathSD59x18__FromIntUnderflow

```solidity
error PRBMathSD59x18__FromIntUnderflow(int256 x)
```

Emitted when converting a basic integer to the fixed-point format underflows SD59x18.

## PRBMathSD59x18__GmNegativeProduct

```solidity
error PRBMathSD59x18__GmNegativeProduct(int256 x, int256 y)
```

Emitted when the product of the inputs is negative.

## PRBMathSD59x18__GmOverflow

```solidity
error PRBMathSD59x18__GmOverflow(int256 x, int256 y)
```

Emitted when multiplying the inputs overflows SD59x18.

## PRBMathSD59x18__LogInputTooSmall

```solidity
error PRBMathSD59x18__LogInputTooSmall(int256 x)
```

Emitted when the input is less than or equal to zero.

## PRBMathSD59x18__MulInputTooSmall

```solidity
error PRBMathSD59x18__MulInputTooSmall()
```

Emitted when one of the inputs is MIN_SD59x18.

## PRBMathSD59x18__MulOverflow

```solidity
error PRBMathSD59x18__MulOverflow(uint256 rAbs)
```

Emitted when the intermediary absolute result overflows SD59x18.

## PRBMathSD59x18__PowuOverflow

```solidity
error PRBMathSD59x18__PowuOverflow(uint256 rAbs)
```

Emitted when the intermediary absolute result overflows SD59x18.

## PRBMathSD59x18__SqrtNegativeInput

```solidity
error PRBMathSD59x18__SqrtNegativeInput(int256 x)
```

Emitted when the input is negative.

## PRBMathSD59x18__SqrtOverflow

```solidity
error PRBMathSD59x18__SqrtOverflow(int256 x)
```

Emitted when the calculating the square root overflows SD59x18.

## PRBMathUD60x18__AddOverflow

```solidity
error PRBMathUD60x18__AddOverflow(uint256 x, uint256 y)
```

Emitted when addition overflows UD60x18.

## PRBMathUD60x18__CeilOverflow

```solidity
error PRBMathUD60x18__CeilOverflow(uint256 x)
```

Emitted when ceiling a number overflows UD60x18.

## PRBMathUD60x18__ExpInputTooBig

```solidity
error PRBMathUD60x18__ExpInputTooBig(uint256 x)
```

Emitted when the input is greater than 133.084258667509499441.

## PRBMathUD60x18__Exp2InputTooBig

```solidity
error PRBMathUD60x18__Exp2InputTooBig(uint256 x)
```

Emitted when the input is greater than 192.

## PRBMathUD60x18__FromUintOverflow

```solidity
error PRBMathUD60x18__FromUintOverflow(uint256 x)
```

Emitted when converting a basic integer to the fixed-point format format overflows UD60x18.

## PRBMathUD60x18__GmOverflow

```solidity
error PRBMathUD60x18__GmOverflow(uint256 x, uint256 y)
```

Emitted when multiplying the inputs overflows UD60x18.

## PRBMathUD60x18__LogInputTooSmall

```solidity
error PRBMathUD60x18__LogInputTooSmall(uint256 x)
```

Emitted when the input is less than 1.

## PRBMathUD60x18__SqrtOverflow

```solidity
error PRBMathUD60x18__SqrtOverflow(uint256 x)
```

Emitted when the calculating the square root overflows UD60x18.

## PRBMathUD60x18__SubUnderflow

```solidity
error PRBMathUD60x18__SubUnderflow(uint256 x, uint256 y)
```

Emitted when subtraction underflows UD60x18.

## PRBMath

_Common mathematical functions used in both PRBMathSD59x18 and PRBMathUD60x18. Note that this shared library
does not always assume the signed 59.18-decimal fixed-point or the unsigned 60.18-decimal fixed-point
representation. When it does not, it is explicitly mentioned in the NatSpec documentation._

### SD59x18

```solidity
struct SD59x18 {
  int256 value;
}
```

### UD60x18

```solidity
struct UD60x18 {
  uint256 value;
}
```

### SCALE

```solidity
uint256 SCALE
```

_How many trailing decimals can be represented._

### SCALE_LPOTD

```solidity
uint256 SCALE_LPOTD
```

_Largest power of two divisor of SCALE._

### SCALE_INVERSE

```solidity
uint256 SCALE_INVERSE
```

_SCALE inverted mod 2^256._

### exp2

```solidity
function exp2(uint256 x) internal pure returns (uint256 result)
```

Calculates the binary exponent of x using the binary fraction method.

_Has to use 192.64-bit fixed-point numbers.
See https://ethereum.stackexchange.com/a/96594/24693._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | uint256 | The exponent as an unsigned 192.64-bit fixed-point number. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | uint256 | The result as an unsigned 60.18-decimal fixed-point number. |

### mostSignificantBit

```solidity
function mostSignificantBit(uint256 x) internal pure returns (uint256 msb)
```

Finds the zero-based index of the first one in the binary representation of x.

_See the note on msb in the "Find First Set" Wikipedia article https://en.wikipedia.org/wiki/Find_first_set_

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | uint256 | The uint256 number for which to find the index of the most significant bit. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| msb | uint256 | The index of the most significant bit as an uint256. |

### mulDiv

```solidity
function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result)
```

Calculates floor(x*y÷denominator) with full precision.

_Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv.

Requirements:
- The denominator cannot be zero.
- The result must fit within uint256.

Caveats:
- This function does not work with fixed-point numbers._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | uint256 | The multiplicand as an uint256. |
| y | uint256 | The multiplier as an uint256. |
| denominator | uint256 | The divisor as an uint256. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | uint256 | The result as an uint256. |

### mulDivFixedPoint

```solidity
function mulDivFixedPoint(uint256 x, uint256 y) internal pure returns (uint256 result)
```

Calculates floor(x*y÷1e18) with full precision.

_Variant of "mulDiv" with constant folding, i.e. in which the denominator is always 1e18. Before returning the
final result, we add 1 if (x * y) % SCALE >= HALF_SCALE. Without this, 6.6e-19 would be truncated to 0 instead of
being rounded to 1e-18.  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717.

Requirements:
- The result must fit within uint256.

Caveats:
- The body is purposely left uncommented; see the NatSpec comments in "PRBMath.mulDiv" to understand how this works.
- It is assumed that the result can never be type(uint256).max when x and y solve the following two equations:
    1. x * y = type(uint256).max * SCALE
    2. (x * y) % SCALE >= SCALE / 2_

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | uint256 | The multiplicand as an unsigned 60.18-decimal fixed-point number. |
| y | uint256 | The multiplier as an unsigned 60.18-decimal fixed-point number. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | uint256 | The result as an unsigned 60.18-decimal fixed-point number. |

### mulDivSigned

```solidity
function mulDivSigned(int256 x, int256 y, int256 denominator) internal pure returns (int256 result)
```

Calculates floor(x*y÷denominator) with full precision.

_An extension of "mulDiv" for signed numbers. Works by computing the signs and the absolute values separately.

Requirements:
- None of the inputs can be type(int256).min.
- The result must fit within int256._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The multiplicand as an int256. |
| y | int256 | The multiplier as an int256. |
| denominator | int256 | The divisor as an int256. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | int256 | The result as an int256. |

### sqrt

```solidity
function sqrt(uint256 x) internal pure returns (uint256 result)
```

Calculates the square root of x, rounding down.

_Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.

Caveats:
- This function does not work with fixed-point numbers._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | uint256 | The uint256 number for which to calculate the square root. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | uint256 | The result as an uint256. |

## PRBMathSD59x18

Smart contract library for advanced fixed-point math that works with int256 numbers considered to have 18
trailing decimals. We call this number representation signed 59.18-decimal fixed-point, since the numbers can have
a sign and there can be up to 59 digits in the integer part and up to 18 decimals in the fractional part. The numbers
are bound by the minimum and the maximum values permitted by the Solidity type int256.

### LOG2_E

```solidity
int256 LOG2_E
```

_log2(e) as a signed 59.18-decimal fixed-point number._

### HALF_SCALE

```solidity
int256 HALF_SCALE
```

_Half the SCALE number._

### MAX_SD59x18

```solidity
int256 MAX_SD59x18
```

_The maximum value a signed 59.18-decimal fixed-point number can have._

### MAX_WHOLE_SD59x18

```solidity
int256 MAX_WHOLE_SD59x18
```

_The maximum whole value a signed 59.18-decimal fixed-point number can have._

### MIN_SD59x18

```solidity
int256 MIN_SD59x18
```

_The minimum value a signed 59.18-decimal fixed-point number can have._

### MIN_WHOLE_SD59x18

```solidity
int256 MIN_WHOLE_SD59x18
```

_The minimum whole value a signed 59.18-decimal fixed-point number can have._

### SCALE

```solidity
int256 SCALE
```

_How many trailing decimals can be represented._

### abs

```solidity
function abs(int256 x) internal pure returns (int256 result)
```

Calculate the absolute value of x.

_Requirements:
- x must be greater than MIN_SD59x18._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The number to calculate the absolute value for. |

### avg

```solidity
function avg(int256 x, int256 y) internal pure returns (int256 result)
```

Calculates the arithmetic average of x and y, rounding down.

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The first operand as a signed 59.18-decimal fixed-point number. |
| y | int256 | The second operand as a signed 59.18-decimal fixed-point number. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | int256 | The arithmetic average as a signed 59.18-decimal fixed-point number. |

### ceil

```solidity
function ceil(int256 x) internal pure returns (int256 result)
```

Yields the least greatest signed 59.18 decimal fixed-point number greater than or equal to x.

_Optimized for fractional value inputs, because for every whole value there are (1e18 - 1) fractional counterparts.
See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.

Requirements:
- x must be less than or equal to MAX_WHOLE_SD59x18._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The signed 59.18-decimal fixed-point number to ceil. |

### div

```solidity
function div(int256 x, int256 y) internal pure returns (int256 result)
```

Divides two signed 59.18-decimal fixed-point numbers, returning a new signed 59.18-decimal fixed-point number.

_Variant of "mulDiv" that works with signed numbers. Works by computing the signs and the absolute values separately.

Requirements:
- All from "PRBMath.mulDiv".
- None of the inputs can be MIN_SD59x18.
- The denominator cannot be zero.
- The result must fit within int256.

Caveats:
- All from "PRBMath.mulDiv"._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The numerator as a signed 59.18-decimal fixed-point number. |
| y | int256 | The denominator as a signed 59.18-decimal fixed-point number. |

### e

```solidity
function e() internal pure returns (int256 result)
```

Returns Euler's number as a signed 59.18-decimal fixed-point number.

_See https://en.wikipedia.org/wiki/E_(mathematical_constant)._

### exp

```solidity
function exp(int256 x) internal pure returns (int256 result)
```

Calculates the natural exponent of x.

_Based on the insight that e^x = 2^(x * log2(e)).

Requirements:
- All from "log2".
- x must be less than 133.084258667509499441.

Caveats:
- All from "exp2".
- For any x less than -41.446531673892822322, the result is zero._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The exponent as a signed 59.18-decimal fixed-point number. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | int256 | The result as a signed 59.18-decimal fixed-point number. |

### exp2

```solidity
function exp2(int256 x) internal pure returns (int256 result)
```

Calculates the binary exponent of x using the binary fraction method.

_See https://ethereum.stackexchange.com/q/79903/24693.

Requirements:
- x must be 192 or less.
- The result must fit within MAX_SD59x18.

Caveats:
- For any x less than -59.794705707972522261, the result is zero._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The exponent as a signed 59.18-decimal fixed-point number. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | int256 | The result as a signed 59.18-decimal fixed-point number. |

### floor

```solidity
function floor(int256 x) internal pure returns (int256 result)
```

Yields the greatest signed 59.18 decimal fixed-point number less than or equal to x.

_Optimized for fractional value inputs, because for every whole value there are (1e18 - 1) fractional counterparts.
See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.

Requirements:
- x must be greater than or equal to MIN_WHOLE_SD59x18._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The signed 59.18-decimal fixed-point number to floor. |

### frac

```solidity
function frac(int256 x) internal pure returns (int256 result)
```

Yields the excess beyond the floor of x for positive numbers and the part of the number to the right
of the radix point for negative numbers.

_Based on the odd function definition. https://en.wikipedia.org/wiki/Fractional_part_

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The signed 59.18-decimal fixed-point number to get the fractional part of. |

### fromInt

```solidity
function fromInt(int256 x) internal pure returns (int256 result)
```

Converts a number from basic integer form to signed 59.18-decimal fixed-point representation.

_Requirements:
- x must be greater than or equal to MIN_SD59x18 divided by SCALE.
- x must be less than or equal to MAX_SD59x18 divided by SCALE._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The basic integer to convert. |

### gm

```solidity
function gm(int256 x, int256 y) internal pure returns (int256 result)
```

Calculates geometric mean of x and y, i.e. sqrt(x * y), rounding down.

_Requirements:
- x * y must fit within MAX_SD59x18, lest it overflows.
- x * y cannot be negative._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The first operand as a signed 59.18-decimal fixed-point number. |
| y | int256 | The second operand as a signed 59.18-decimal fixed-point number. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | int256 | The result as a signed 59.18-decimal fixed-point number. |

### inv

```solidity
function inv(int256 x) internal pure returns (int256 result)
```

Calculates 1 / x, rounding toward zero.

_Requirements:
- x cannot be zero._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The signed 59.18-decimal fixed-point number for which to calculate the inverse. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | int256 | The inverse as a signed 59.18-decimal fixed-point number. |

### ln

```solidity
function ln(int256 x) internal pure returns (int256 result)
```

Calculates the natural logarithm of x.

_Based on the insight that ln(x) = log2(x) / log2(e).

Requirements:
- All from "log2".

Caveats:
- All from "log2".
- This doesn't return exactly 1 for 2718281828459045235, for that we would need more fine-grained precision._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The signed 59.18-decimal fixed-point number for which to calculate the natural logarithm. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | int256 | The natural logarithm as a signed 59.18-decimal fixed-point number. |

### log10

```solidity
function log10(int256 x) internal pure returns (int256 result)
```

Calculates the common logarithm of x.

_First checks if x is an exact power of ten and it stops if yes. If it's not, calculates the common
logarithm based on the insight that log10(x) = log2(x) / log2(10).

Requirements:
- All from "log2".

Caveats:
- All from "log2"._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The signed 59.18-decimal fixed-point number for which to calculate the common logarithm. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | int256 | The common logarithm as a signed 59.18-decimal fixed-point number. |

### log2

```solidity
function log2(int256 x) internal pure returns (int256 result)
```

Calculates the binary logarithm of x.

_Based on the iterative approximation algorithm.
https://en.wikipedia.org/wiki/Binary_logarithm#Iterative_approximation

Requirements:
- x must be greater than zero.

Caveats:
- The results are not perfectly accurate to the last decimal, due to the lossy precision of the iterative approximation._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The signed 59.18-decimal fixed-point number for which to calculate the binary logarithm. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | int256 | The binary logarithm as a signed 59.18-decimal fixed-point number. |

### mul

```solidity
function mul(int256 x, int256 y) internal pure returns (int256 result)
```

Multiplies two signed 59.18-decimal fixed-point numbers together, returning a new signed 59.18-decimal
fixed-point number.

_Variant of "mulDiv" that works with signed numbers and employs constant folding, i.e. the denominator is
always 1e18.

Requirements:
- All from "PRBMath.mulDivFixedPoint".
- None of the inputs can be MIN_SD59x18
- The result must fit within MAX_SD59x18.

Caveats:
- The body is purposely left uncommented; see the NatSpec comments in "PRBMath.mulDiv" to understand how this works._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The multiplicand as a signed 59.18-decimal fixed-point number. |
| y | int256 | The multiplier as a signed 59.18-decimal fixed-point number. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | int256 | The product as a signed 59.18-decimal fixed-point number. |

### pi

```solidity
function pi() internal pure returns (int256 result)
```

Returns PI as a signed 59.18-decimal fixed-point number.

### pow

```solidity
function pow(int256 x, int256 y) internal pure returns (int256 result)
```

Raises x to the power of y.

_Based on the insight that x^y = 2^(log2(x) * y).

Requirements:
- All from "exp2", "log2" and "mul".
- z cannot be zero.

Caveats:
- All from "exp2", "log2" and "mul".
- Assumes 0^0 is 1._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | Number to raise to given power y, as a signed 59.18-decimal fixed-point number. |
| y | int256 | Exponent to raise x to, as a signed 59.18-decimal fixed-point number. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | int256 | x raised to power y, as a signed 59.18-decimal fixed-point number. |

### powu

```solidity
function powu(int256 x, uint256 y) internal pure returns (int256 result)
```

Raises x (signed 59.18-decimal fixed-point number) to the power of y (basic unsigned integer) using the
famous algorithm "exponentiation by squaring".

_See https://en.wikipedia.org/wiki/Exponentiation_by_squaring

Requirements:
- All from "abs" and "PRBMath.mulDivFixedPoint".
- The result must fit within MAX_SD59x18.

Caveats:
- All from "PRBMath.mulDivFixedPoint".
- Assumes 0^0 is 1._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The base as a signed 59.18-decimal fixed-point number. |
| y | uint256 | The exponent as an uint256. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | int256 | The result as a signed 59.18-decimal fixed-point number. |

### scale

```solidity
function scale() internal pure returns (int256 result)
```

Returns 1 as a signed 59.18-decimal fixed-point number.

### sqrt

```solidity
function sqrt(int256 x) internal pure returns (int256 result)
```

Calculates the square root of x, rounding down.

_Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.

Requirements:
- x cannot be negative.
- x must be less than MAX_SD59x18 / SCALE._

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The signed 59.18-decimal fixed-point number for which to calculate the square root. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | int256 | The result as a signed 59.18-decimal fixed-point . |

### toInt

```solidity
function toInt(int256 x) internal pure returns (int256 result)
```

Converts a signed 59.18-decimal fixed-point number to basic integer form, rounding down in the process.

| Name | Type | Description |
| ---- | ---- | ----------- |
| x | int256 | The signed 59.18-decimal fixed-point number to convert. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | int256 | The same number in basic integer form. |

## Complex

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

### sub

```solidity
function sub(int256 re, int256 im, int256 re1, int256 im1) public pure returns (int256, int256)
```

### mul

```solidity
function mul(int256 re, int256 im, int256 re1, int256 im1) public pure returns (int256, int256)
```

### div

```solidity
function div(int256 re, int256 im, int256 re1, int256 im1) public pure returns (int256, int256)
```

### r2

```solidity
function r2(int256 a, int256 b) public pure returns (int256)
```

### toPolar

```solidity
function toPolar(int256 re, int256 im) public pure returns (int256, int256)
```

### fromPolar

```solidity
function fromPolar(int256 r, int256 T) public pure returns (int256 re, int256 im)
```

### atan2

```solidity
function atan2(int256 y, int256 x) public pure returns (int256 T)
```

### p_atan2

```solidity
function p_atan2(int256 y, int256 x) public pure returns (int256 T)
```

### atan1to1

```solidity
function atan1to1(int256 x) public pure returns (int256)
```

### complexLN

```solidity
function complexLN(int256 re, int256 im) public pure returns (int256, int256)
```

### complexSQRT

```solidity
function complexSQRT(int256 re, int256 im) public pure returns (int256, int256)
```

### complexEXP

```solidity
function complexEXP(int256 re, int256 im) public pure returns (int256, int256)
```

### complexPOW

```solidity
function complexPOW(int256 re, int256 im, int256 n) public pure returns (int256, int256)
```

