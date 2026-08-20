import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import Decimal from "decimal.js";

Decimal.set({ precision: 80, rounding: Decimal.ROUND_HALF_EVEN });

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(scriptDirectory, "..");
const outputPath = path.join(root, "test", "fixtures", "OracleVectors.sol");
const trigonometryPath = path.join(root, "contracts", "Trigonometry.sol");

const D = (value) => new Decimal(value.toString());
const UNIT = D("1e18");
const UNIT_RAW = 1_000_000_000_000_000_000n;
const PI = Decimal.acos(-1);
const TWO_PI = PI.mul(2);
const TWO_PI_RAW = 6_283_185_307_179_586_476n;
const MAX_RAW = (1n << 255n) - 1n;
const MIN_RAW = -(1n << 255n);
const MAX_ANGLE_RAW = 10n ** 28n;
const INT32_MAX = D(2_147_483_647);
const CYCLE_SIZE = D(1_073_741_824);
const TRIG_ENVELOPE = D("0.00000482");
const ATAN_ENVELOPE = D("0.00151");

function toRaw(value) {
    return BigInt(D(value).mul(UNIT).toDecimalPlaces(0, Decimal.ROUND_HALF_EVEN).toFixed(0));
}

function fromRaw(value) {
    return D(value).div(UNIT);
}

function absBigInt(value) {
    return value < 0n ? -value : value;
}

function decimalCeilToBigInt(value) {
    return BigInt(D(value).toDecimalPlaces(0, Decimal.ROUND_CEIL).toFixed(0));
}

function complexSqrt(reRaw, imRaw) {
    const re = fromRaw(reRaw);
    const im = fromRaw(imRaw);
    const radius = re.mul(re).add(im.mul(im)).sqrt();
    const real = radius.add(re).div(2).sqrt();
    const imaginaryMagnitude = radius.sub(re).div(2).sqrt();
    return [toRaw(real), toRaw(im.isNegative() ? imaginaryMagnitude.neg() : imaginaryMagnitude)];
}

function complexDiv(aRe, aIm, bRe, bIm) {
    const denominator = bRe * bRe + bIm * bIm;
    return [
        ((aRe * bRe + aIm * bIm) * UNIT_RAW) / denominator,
        ((aIm * bRe - aRe * bIm) * UNIT_RAW) / denominator,
    ];
}

function complexLog(reRaw, imRaw) {
    const re = fromRaw(reRaw);
    const im = fromRaw(imRaw);
    const radius = re.mul(re).add(im.mul(im)).sqrt();
    return [toRaw(radius.ln()), toRaw(Decimal.atan2(im, re))];
}

function complexExp(reRaw, imRaw) {
    const re = fromRaw(reRaw);
    const im = fromRaw(imRaw);
    const scale = re.exp();
    return [toRaw(scale.mul(im.cos())), toRaw(scale.mul(im.sin()))];
}

function complexPow(reRaw, imRaw, exponentRaw) {
    const re = fromRaw(reRaw);
    const im = fromRaw(imRaw);
    const exponent = fromRaw(exponentRaw);
    const radius = re.mul(re).add(im.mul(im)).sqrt();
    const phase = Decimal.atan2(im, re).mul(exponent);
    const scale = radius.pow(exponent);
    return [toRaw(scale.mul(phase.cos())), toRaw(scale.mul(phase.sin()))];
}

function analyzeTrigTable() {
    const source = fs.readFileSync(trigonometryPath, "utf8");
    const match = source.match(/hex"([0-9a-f]+)"/u);
    if (!match) throw new Error("Unable to locate the sine lookup table");
    const hex = match[1];
    if (hex.length !== 257 * 8) throw new Error(`Expected 257 sine entries, found ${hex.length / 8}`);

    const table = [];
    for (let index = 0; index < 257; index += 1) {
        table.push(D(BigInt(`0x${hex.slice(index * 8, index * 8 + 8)}`)).div(INT32_MAX));
    }

    let interpolationError = D(0);
    for (let index = 0; index < 256; index += 1) {
        const x0 = PI.mul(index).div(512);
        const x1 = PI.mul(index + 1).div(512);
        const y0 = table[index];
        const y1 = table[index + 1];
        const slope = y1.sub(y0).div(x1.sub(x0));
        const candidates = [x0, x1];
        if (slope.greaterThanOrEqualTo(0) && slope.lessThanOrEqualTo(1)) {
            const critical = Decimal.acos(slope);
            if (critical.greaterThan(x0) && critical.lessThan(x1)) candidates.push(critical);
        }
        for (const x of candidates) {
            const interpolated = y0.add(y1.sub(y0).mul(x.sub(x0)).div(x1.sub(x0)));
            interpolationError = Decimal.max(interpolationError, interpolated.sub(x.sin()).abs());
        }
    }

    const lookupQuantization = TWO_PI.mul(15).div(CYCLE_SIZE);
    const cycleQuantization = TWO_PI.div(CYCLE_SIZE);
    const representedPeriod = D(TWO_PI_RAW).div(UNIT);
    const rangeReductionError = D(MAX_ANGLE_RAW).div(UNIT).div(TWO_PI).mul(TWO_PI.sub(representedPeriod).abs());
    return interpolationError.add(lookupQuantization).add(cycleQuantization).add(rangeReductionError);
}

function atanApproximation(x) {
    const absX = x.abs();
    return PI.div(4).mul(x).sub(x.mul(absX.sub(1)).mul(D("0.2447").add(D("0.0663").mul(absX))));
}

function analyzeAtan() {
    const derivative = (x) =>
        PI.div(4)
            .add(D("0.2447"))
            .add(D(2).mul(D("0.0663").sub(D("0.2447"))).mul(x))
            .sub(D(3).mul(D("0.0663")).mul(x).mul(x))
            .sub(D(1).div(D(1).add(x.mul(x))));
    const candidates = [D(0), D(1)];
    let previousX = D(0);
    let previousValue = derivative(previousX);
    for (let index = 1; index <= 10_000; index += 1) {
        const x = D(index).div(10_000);
        const value = derivative(x);
        if (previousValue.isZero() || value.isZero() || previousValue.isNegative() !== value.isNegative()) {
            let low = previousX;
            let high = x;
            for (let iteration = 0; iteration < 100; iteration += 1) {
                const middle = low.add(high).div(2);
                if (derivative(low).isNegative() !== derivative(middle).isNegative()) high = middle;
                else low = middle;
            }
            candidates.push(low.add(high).div(2));
        }
        previousX = x;
        previousValue = value;
    }
    return candidates.reduce(
        (maximum, x) => Decimal.max(maximum, atanApproximation(x).sub(x.atan()).abs()),
        D(0),
    );
}

const angleInputs = [
    -MAX_ANGLE_RAW,
    -TWO_PI_RAW,
    -3_141_592_653_589_793_238n,
    -1_570_796_326_794_896_619n,
    -1_047_197_551_196_597_746n,
    -785_398_163_397_448_309n,
    -476_950_000_000_000_000n,
    0n,
    476_950_000_000_000_000n,
    785_398_163_397_448_309n,
    1_047_197_551_196_597_746n,
    1_570_796_326_794_896_619n,
    3_141_592_653_589_793_238n,
    TWO_PI_RAW,
    MAX_ANGLE_RAW,
];

const atanInputs = [
    [0n, 1_000_000_000_000_000_000n],
    [0n, -1_000_000_000_000_000_000n],
    [1_000_000_000_000_000_000n, 0n],
    [-1_000_000_000_000_000_000n, 0n],
    [1_000_000_000_000_000_000n, 1_000_000_000_000_000_000n],
    [1_000_000_000_000_000_000n, -1_000_000_000_000_000_000n],
    [-1_000_000_000_000_000_000n, -1_000_000_000_000_000_000n],
    [-1_000_000_000_000_000_000n, 1_000_000_000_000_000_000n],
    [476_950_000_000_000_000n, 1_000_000_000_000_000_000n],
    [-476_950_000_000_000_000n, 1_000_000_000_000_000_000n],
    [1n, MIN_RAW],
    [MIN_RAW, 1n],
];

const magnitudeInputs = [
    [0n, 0n],
    [1n, 1n],
    [3_000_000_000_000_000_000n, 4_000_000_000_000_000_000n],
    [-5_000_000_000_000_000_000n, 12_000_000_000_000_000_000n],
    [10n ** 48n, 10n ** 39n],
    [4n * 10n ** 48n, 3n * 10n ** 48n],
];

const divisionInputs = [
    [1n * UNIT_RAW, 2n * UNIT_RAW, 3n * UNIT_RAW, 4n * UNIT_RAW],
    [0n, 1n, 2n, 1n],
    [0n, 10n ** 36n, 2n * UNIT_RAW, 1n],
    [MAX_RAW, MAX_RAW, MAX_RAW, MAX_RAW],
    [MAX_RAW, MAX_RAW, UNIT_RAW, UNIT_RAW],
    [MIN_RAW, MIN_RAW, UNIT_RAW, -UNIT_RAW],
    [MIN_RAW, MIN_RAW, MIN_RAW, MIN_RAW],
    [MAX_RAW / 3n, -(MAX_RAW / 7n), MAX_RAW / 11n, MAX_RAW / 13n],
    [1n, -1n, MAX_RAW, MIN_RAW],
];

const sqrtInputs = [
    [3_000_000_000_000_000_000n, 4_000_000_000_000_000_000n],
    [3_000_000_000_000_000_000n, -4_000_000_000_000_000_000n],
    [-4_000_000_000_000_000_000n, 0n],
    [0n, 1n],
    [10n ** 38n, 10n ** 23n],
    [10n ** 60n, 1_000_000_000_000_000_000n],
    [-(10n ** 60n), 1_000_000_000_000_000_000n],
];

const logInputs = [
    [1_000_000_000_000_000_000n, 0n],
    [-1_000_000_000_000_000_000n, 0n],
    [1_000_000_000_000_000_000n, 1_000_000_000_000_000_000n],
    [3_000_000_000_000_000_000n, 4_000_000_000_000_000_000n],
];

const expInputs = [
    [0n, 0n],
    [0n, 3_141_592_653_589_793_238n],
    [1_000_000_000_000_000_000n, 1_047_197_551_196_597_746n],
    [-2_000_000_000_000_000_000n, -785_398_163_397_448_309n],
    [-41_446_531_673_892_822_323n, 0n],
    [-41_446_531_673_892_822_322n, 0n],
    [133_084_258_667_509_499_440n, 0n],
];

const powInputs = [
    [0n, 4_000_000_000_000_000_000n, 500_000_000_000_000_000n],
    [1_000_000_000_000_000_000n, 1_000_000_000_000_000_000n, 2_500_000_000_000_000_000n],
    [-2_000_000_000_000_000_000n, 3_000_000_000_000_000_000n, -500_000_000_000_000_000n],
    [1_000_000_000_000_000_000n, 476_950_000_000_000_000n, 10_000_000_000_000_000_000n],
];

function returnBranches(vectors) {
    return vectors
        .map((vector, index) => `        if (index == ${index}) return (${vector.join(", ")});`)
        .join("\n");
}

const polarVectors = angleInputs.map((angle) => {
    const radians = fromRaw(angle);
    return [angle, toRaw(radians.cos()), toRaw(radians.sin())];
});
const atanVectors = atanInputs.map(([y, x]) => [y, x, toRaw(Decimal.atan2(fromRaw(y), fromRaw(x)))]);
const magnitudeVectors = magnitudeInputs.map(([re, im]) => {
    const expected = toRaw(fromRaw(re).mul(fromRaw(re)).add(fromRaw(im).mul(fromRaw(im))).sqrt());
    const tolerance = decimalCeilToBigInt(D(absBigInt(expected)).mul("2e-18").add(4));
    return [re, im, expected, tolerance];
});
const divisionVectors = divisionInputs.map(([aRe, aIm, bRe, bIm]) => {
    const [expectedRe, expectedIm] = complexDiv(aRe, aIm, bRe, bIm);
    if (expectedRe < MIN_RAW || expectedRe > MAX_RAW || expectedIm < MIN_RAW || expectedIm > MAX_RAW) {
        throw new Error("Division oracle result is outside SD59x18");
    }
    return [aRe, aIm, bRe, bIm, expectedRe, expectedIm];
});
const sqrtVectors = sqrtInputs.map(([re, im]) => {
    const [expectedRe, expectedIm] = complexSqrt(re, im);
    const tolerance = absBigInt(re) > 10n ** 59n || absBigInt(im) > 10n ** 59n ? 1_000_000_000n : 5n;
    return [re, im, expectedRe, expectedIm, tolerance];
});
const logVectors = logInputs.map(([re, im]) => {
    const [expectedRe, expectedIm] = complexLog(re, im);
    return [re, im, expectedRe, expectedIm, 100n, 1_510_000_000_000_000n];
});
const expVectors = expInputs.map(([re, im]) => {
    const [expectedRe, expectedIm] = complexExp(re, im);
    const scale = Decimal.max(D(absBigInt(expectedRe)), D(absBigInt(expectedIm)));
    const tolerance = decimalCeilToBigInt(scale.mul(TRIG_ENVELOPE).add(1_000));
    return [re, im, expectedRe, expectedIm, tolerance];
});
const powVectors = powInputs.map(([re, im, exponent]) => {
    const [expectedRe, expectedIm] = complexPow(re, im, exponent);
    const scale = Decimal.max(D(absBigInt(expectedRe)), D(absBigInt(expectedIm)));
    const phaseEnvelope = fromRaw(exponent).abs().mul(ATAN_ENVELOPE).add(TRIG_ENVELOPE);
    const tolerance = decimalCeilToBigInt(scale.mul(phaseEnvelope).add(1_000));
    return [re, im, exponent, expectedRe, expectedIm, tolerance];
});

const generated = `// SPDX-License-Identifier: MIT
// This file is generated by scripts/generate-oracle-vectors.mjs. Do not edit manually.
pragma solidity 0.8.36;

library OracleVectors {
    error IndexOutOfBounds();

    function polarCount() internal pure returns (uint256) { return ${polarVectors.length}; }
    function polar(uint256 index) internal pure returns (int256 angle, int256 expectedRe, int256 expectedIm) {
${returnBranches(polarVectors)}
        revert IndexOutOfBounds();
    }

    function atanCount() internal pure returns (uint256) { return ${atanVectors.length}; }
    function atan(uint256 index) internal pure returns (int256 y, int256 x, int256 expected) {
${returnBranches(atanVectors)}
        revert IndexOutOfBounds();
    }

    function magnitudeCount() internal pure returns (uint256) { return ${magnitudeVectors.length}; }
    function magnitude(uint256 index) internal pure returns (int256 re, int256 im, int256 expected, int256 tolerance) {
${returnBranches(magnitudeVectors)}
        revert IndexOutOfBounds();
    }

    function divisionCount() internal pure returns (uint256) { return ${divisionVectors.length}; }
    function division(uint256 index) internal pure returns (int256 aRe, int256 aIm, int256 bRe, int256 bIm, int256 expectedRe, int256 expectedIm) {
${returnBranches(divisionVectors)}
        revert IndexOutOfBounds();
    }

    function sqrtCount() internal pure returns (uint256) { return ${sqrtVectors.length}; }
    function sqrt(uint256 index) internal pure returns (int256 re, int256 im, int256 expectedRe, int256 expectedIm, int256 tolerance) {
${returnBranches(sqrtVectors)}
        revert IndexOutOfBounds();
    }

    function logCount() internal pure returns (uint256) { return ${logVectors.length}; }
    function log(uint256 index) internal pure returns (int256 re, int256 im, int256 expectedRe, int256 expectedIm, int256 reTolerance, int256 imTolerance) {
${returnBranches(logVectors)}
        revert IndexOutOfBounds();
    }

    function expCount() internal pure returns (uint256) { return ${expVectors.length}; }
    function exp(uint256 index) internal pure returns (int256 re, int256 im, int256 expectedRe, int256 expectedIm, int256 tolerance) {
${returnBranches(expVectors)}
        revert IndexOutOfBounds();
    }

    function powCount() internal pure returns (uint256) { return ${powVectors.length}; }
    function pow(uint256 index) internal pure returns (int256 re, int256 im, int256 exponent, int256 expectedRe, int256 expectedIm, int256 tolerance) {
${returnBranches(powVectors)}
        revert IndexOutOfBounds();
    }
}
`;
const trigBound = analyzeTrigTable();
const atanBound = analyzeAtan();
if (trigBound.greaterThan(TRIG_ENVELOPE)) {
    throw new Error(`Trigonometric bound ${trigBound} exceeds ${TRIG_ENVELOPE}`);
}
if (atanBound.greaterThan(ATAN_ENVELOPE)) {
    throw new Error(`atan bound ${atanBound} exceeds ${ATAN_ENVELOPE}`);
}

if (process.argv.includes("--write")) {
    fs.mkdirSync(path.dirname(outputPath), { recursive: true });
    fs.writeFileSync(outputPath, generated);
} else if (!fs.existsSync(outputPath) || fs.readFileSync(outputPath, "utf8") !== generated) {
    throw new Error("Oracle vectors are stale; run `npm run oracle:write`");
}

console.log(
    JSON.stringify({
        trigAbsoluteErrorBound: trigBound.toSignificantDigits(12).toString(),
        atanAbsoluteErrorBound: atanBound.toSignificantDigits(12).toString(),
        vectors: polarVectors.length + atanVectors.length + magnitudeVectors.length + divisionVectors.length + sqrtVectors.length + logVectors.length + expVectors.length + powVectors.length,
    }),
);
