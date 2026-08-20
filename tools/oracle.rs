use rug::float::{Constant, Round};
use rug::ops::Pow;
use rug::{Complex, Float, Integer};
use std::env;
use std::error::Error;
use std::fmt::Write as _;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

const PRECISION: u32 = 320;
const UNIT_RAW: &str = "1000000000000000000";
const TWO_PI_RAW: &str = "6283185307179586476";
const MAX_ANGLE_RAW: &str = "10000000000000000000000000000";
const TRIG_ENVELOPE: &str = "0.00000482";
const ATAN_ENVELOPE: &str = "0.00151";

fn integer(value: &str) -> Integer {
    value.parse().expect("valid integer literal")
}

fn float(value: &str) -> Float {
    Float::with_val(PRECISION, Float::parse(value).expect("valid float literal"))
}

fn unit() -> Integer {
    integer(UNIT_RAW)
}

fn max_raw() -> Integer {
    (Integer::from(1) << 255) - 1
}

fn min_raw() -> Integer {
    let magnitude: Integer = Integer::from(1) << 255;
    -magnitude
}

fn pow10(exponent: u32) -> Integer {
    Integer::from(10).pow(exponent)
}

fn from_raw(value: &Integer) -> Float {
    let mut result = Float::with_val(PRECISION, value);
    result /= integer(UNIT_RAW);
    result
}

fn to_raw(value: &Float) -> Integer {
    let mut scaled = value.clone();
    scaled *= integer(UNIT_RAW);
    scaled
        .to_integer_round(Round::Nearest)
        .expect("finite oracle value")
        .0
}

fn ceil_ratio(numerator: Integer, denominator: &Integer) -> Integer {
    (numerator + denominator - 1) / denominator
}

fn oracle_complex(re_raw: &Integer, im_raw: &Integer) -> Complex {
    Complex::with_val(PRECISION, (from_raw(re_raw), from_raw(im_raw)))
}

fn complex_sqrt(re_raw: &Integer, im_raw: &Integer) -> (Integer, Integer) {
    let result = oracle_complex(re_raw, im_raw).sqrt();
    (to_raw(result.real()), to_raw(result.imag()))
}

fn complex_log(re_raw: &Integer, im_raw: &Integer) -> (Integer, Integer) {
    let result = oracle_complex(re_raw, im_raw).ln();
    (to_raw(result.real()), to_raw(result.imag()))
}

fn complex_exp(re_raw: &Integer, im_raw: &Integer) -> (Integer, Integer) {
    let result = oracle_complex(re_raw, im_raw).exp();
    (to_raw(result.real()), to_raw(result.imag()))
}

fn complex_pow(re_raw: &Integer, im_raw: &Integer, exponent_raw: &Integer) -> (Integer, Integer) {
    let result = oracle_complex(re_raw, im_raw).pow(from_raw(exponent_raw));
    (to_raw(result.real()), to_raw(result.imag()))
}

fn complex_div(
    a_re: &Integer,
    a_im: &Integer,
    b_re: &Integer,
    b_im: &Integer,
) -> (Integer, Integer) {
    let denominator = Integer::from(b_re * b_re) + Integer::from(b_im * b_im);
    let real_numerator = Integer::from(a_re * b_re) + Integer::from(a_im * b_im);
    let imaginary_numerator = Integer::from(a_im * b_re) - Integer::from(a_re * b_im);
    (
        (real_numerator * unit()) / &denominator,
        (imaginary_numerator * unit()) / denominator,
    )
}

fn analyze_trig_table(root: &Path) -> Result<Float, Box<dyn Error>> {
    let source = fs::read_to_string(root.join("contracts/Trigonometry.sol"))?;
    let start = source
        .find("hex\"")
        .ok_or("unable to locate the sine lookup table")?
        + 4;
    let rest = &source[start..];
    let end = rest.find('"').ok_or("unterminated sine lookup table")?;
    let hex = &rest[..end];
    if hex.len() != 257 * 8 {
        return Err(format!("expected 257 sine entries, found {}", hex.len() / 8).into());
    }

    let denominator = Float::with_val(PRECISION, 2_147_483_647_u32);
    let mut table = Vec::with_capacity(257);
    for index in 0..257 {
        let entry = u32::from_str_radix(&hex[index * 8..index * 8 + 8], 16)?;
        let mut value = Float::with_val(PRECISION, entry);
        value /= &denominator;
        table.push(value);
    }

    let pi = Float::with_val(PRECISION, Constant::Pi);
    let mut interpolation_error = Float::with_val(PRECISION, 0);
    for index in 0..256 {
        let mut x0 = Float::with_val(PRECISION, &pi * index);
        x0 /= 512;
        let mut x1 = Float::with_val(PRECISION, &pi * (index + 1));
        x1 /= 512;
        let y0 = &table[index];
        let y1 = &table[index + 1];

        let mut slope = y1.clone();
        slope -= y0;
        let mut width = x1.clone();
        width -= &x0;
        slope /= width;

        let mut candidates = vec![x0.clone(), x1.clone()];
        if (0..=1).contains(&slope) {
            let critical = slope.acos();
            if critical > x0 && critical < x1 {
                candidates.push(critical);
            }
        }

        for x in candidates {
            let mut interpolated = y1.clone();
            interpolated -= y0;
            let mut offset = x.clone();
            offset -= &x0;
            interpolated *= offset;
            let mut width = x1.clone();
            width -= &x0;
            interpolated /= width;
            interpolated += y0;

            let mut error = interpolated;
            error -= x.sin();
            error.abs_mut();
            if error > interpolation_error {
                interpolation_error = error;
            }
        }
    }

    let mut two_pi = pi;
    two_pi *= 2;
    let cycle_size = Float::with_val(PRECISION, 1_073_741_824_u64);
    let mut lookup_quantization = two_pi.clone();
    lookup_quantization *= 15;
    lookup_quantization /= &cycle_size;
    let mut cycle_quantization = two_pi.clone();
    cycle_quantization /= &cycle_size;

    let represented_period = from_raw(&integer(TWO_PI_RAW));
    let mut period_error = two_pi.clone();
    period_error -= represented_period;
    period_error.abs_mut();
    let mut range_reduction_error = from_raw(&integer(MAX_ANGLE_RAW));
    range_reduction_error /= &two_pi;
    range_reduction_error *= period_error;

    interpolation_error += lookup_quantization;
    interpolation_error += cycle_quantization;
    interpolation_error += range_reduction_error;
    Ok(interpolation_error)
}

fn atan_approximation(x: &Float, pi: &Float) -> Float {
    let mut result = pi.clone();
    result /= 4;
    result *= x;

    let mut abs_x = x.clone();
    abs_x.abs_mut();
    let mut distance = abs_x.clone();
    distance -= 1;
    let mut coefficient = float("0.0663");
    coefficient *= abs_x;
    coefficient += float("0.2447");
    let mut correction = x.clone();
    correction *= distance;
    correction *= coefficient;
    result -= correction;
    result
}

fn atan_error_derivative(x: &Float, pi: &Float) -> Float {
    let mut result = pi.clone();
    result /= 4;
    result += float("0.2447");

    let mut linear = float("0.0663");
    linear -= float("0.2447");
    linear *= 2;
    linear *= x;
    result += linear;

    let mut x_squared = x.clone();
    x_squared.square_mut();
    let mut quadratic = x_squared.clone();
    quadratic *= float("0.0663");
    quadratic *= 3;
    result -= &quadratic;

    x_squared += 1;
    let mut reciprocal = Float::with_val(PRECISION, 1);
    reciprocal /= x_squared;
    result -= reciprocal;
    result
}

fn analyze_atan() -> Float {
    let pi = Float::with_val(PRECISION, Constant::Pi);
    let mut candidates = vec![Float::with_val(PRECISION, 0), Float::with_val(PRECISION, 1)];
    let mut previous_x = Float::with_val(PRECISION, 0);
    let mut previous_value = atan_error_derivative(&previous_x, &pi);

    for index in 1..=10_000 {
        let mut x = Float::with_val(PRECISION, index);
        x /= 10_000;
        let value = atan_error_derivative(&x, &pi);
        if previous_value == 0
            || value == 0
            || previous_value.is_sign_negative() != value.is_sign_negative()
        {
            let mut low = previous_x.clone();
            let mut high = x.clone();
            for _ in 0..100 {
                let mut middle = low.clone();
                middle += &high;
                middle /= 2;
                let low_negative = atan_error_derivative(&low, &pi).is_sign_negative();
                let middle_negative = atan_error_derivative(&middle, &pi).is_sign_negative();
                if low_negative != middle_negative {
                    high = middle;
                } else {
                    low = middle;
                }
            }
            low += high;
            low /= 2;
            candidates.push(low);
        }
        previous_x = x;
        previous_value = value;
    }

    let mut maximum = Float::with_val(PRECISION, 0);
    for x in candidates {
        let mut error = atan_approximation(&x, &pi);
        error -= x.atan();
        error.abs_mut();
        if error > maximum {
            maximum = error;
        }
    }
    maximum
}

fn angle_inputs() -> Vec<Integer> {
    [
        "-10000000000000000000000000000",
        "-6283185307179586476",
        "-3141592653589793238",
        "-1570796326794896619",
        "-1047197551196597746",
        "-785398163397448309",
        "-476950000000000000",
        "0",
        "476950000000000000",
        "785398163397448309",
        "1047197551196597746",
        "1570796326794896619",
        "3141592653589793238",
        "6283185307179586476",
        "10000000000000000000000000000",
    ]
    .into_iter()
    .map(integer)
    .collect()
}

fn atan_inputs() -> Vec<Vec<Integer>> {
    let max = max_raw();
    let min = min_raw();
    vec![
        vec![integer("0"), unit()],
        vec![integer("0"), -unit()],
        vec![unit(), integer("0")],
        vec![-unit(), integer("0")],
        vec![unit(), unit()],
        vec![unit(), -unit()],
        vec![-unit(), -unit()],
        vec![-unit(), unit()],
        vec![integer("476950000000000000"), unit()],
        vec![integer("-476950000000000000"), unit()],
        vec![integer("1"), min.clone()],
        vec![min, integer("1")],
        vec![integer("1"), max],
    ]
}

fn magnitude_inputs() -> Vec<Vec<Integer>> {
    vec![
        vec![integer("0"), integer("0")],
        vec![integer("1"), integer("1")],
        vec![
            integer("3000000000000000000"),
            integer("4000000000000000000"),
        ],
        vec![
            integer("-5000000000000000000"),
            integer("12000000000000000000"),
        ],
        vec![pow10(48), pow10(39)],
        vec![Integer::from(4) * pow10(48), Integer::from(3) * pow10(48)],
    ]
}

fn division_inputs() -> Vec<Vec<Integer>> {
    let max = max_raw();
    let min = min_raw();
    vec![
        vec![
            unit(),
            Integer::from(2) * unit(),
            Integer::from(3) * unit(),
            Integer::from(4) * unit(),
        ],
        vec![integer("0"), integer("1"), integer("2"), integer("1")],
        vec![
            integer("0"),
            pow10(36),
            Integer::from(2) * unit(),
            integer("1"),
        ],
        vec![max.clone(), max.clone(), max.clone(), max.clone()],
        vec![max.clone(), max.clone(), unit(), unit()],
        vec![min.clone(), min.clone(), unit(), -unit()],
        vec![min.clone(), min.clone(), min.clone(), min.clone()],
        vec![
            Integer::from(&max / 3),
            -Integer::from(&max / 7),
            Integer::from(&max / 11),
            Integer::from(&max / 13),
        ],
        vec![integer("1"), integer("-1"), max, min],
    ]
}

fn sqrt_inputs() -> Vec<Vec<Integer>> {
    vec![
        vec![
            integer("3000000000000000000"),
            integer("4000000000000000000"),
        ],
        vec![
            integer("3000000000000000000"),
            integer("-4000000000000000000"),
        ],
        vec![integer("-4000000000000000000"), integer("0")],
        vec![integer("0"), integer("1")],
        vec![pow10(38), pow10(23)],
        vec![pow10(60), unit()],
        vec![-pow10(60), unit()],
    ]
}

fn log_inputs() -> Vec<Vec<Integer>> {
    vec![
        vec![unit(), integer("0")],
        vec![-unit(), integer("0")],
        vec![unit(), unit()],
        vec![Integer::from(3) * unit(), Integer::from(4) * unit()],
    ]
}

fn exp_inputs() -> Vec<Vec<Integer>> {
    vec![
        vec![integer("0"), integer("0")],
        vec![integer("0"), integer("3141592653589793238")],
        vec![unit(), integer("1047197551196597746")],
        vec![
            integer("-2000000000000000000"),
            integer("-785398163397448309"),
        ],
        vec![integer("-41446531673892822323"), integer("0")],
        vec![integer("-41446531673892822322"), integer("0")],
        vec![integer("133084258667509499440"), integer("0")],
    ]
}

fn pow_inputs() -> Vec<Vec<Integer>> {
    vec![
        vec![
            integer("0"),
            integer("4000000000000000000"),
            integer("500000000000000000"),
        ],
        vec![unit(), unit(), integer("2500000000000000000")],
        vec![
            integer("-2000000000000000000"),
            integer("3000000000000000000"),
            integer("-500000000000000000"),
        ],
        vec![
            unit(),
            integer("476950000000000000"),
            integer("10000000000000000000"),
        ],
    ]
}

fn magnitude(re: &Integer, im: &Integer) -> Float {
    let re = from_raw(re);
    let im = from_raw(im);
    let mut result = re.clone();
    result.square_mut();
    let mut im_squared = im;
    im_squared.square_mut();
    result += im_squared;
    result.sqrt()
}

fn maximum_abs(a: &Integer, b: &Integer) -> Integer {
    let a = a.clone().abs();
    let b = b.clone().abs();
    if a >= b { a } else { b }
}

fn return_branches(vectors: &[Vec<Integer>]) -> String {
    let mut output = String::new();
    for (index, vector) in vectors.iter().enumerate() {
        let values = vector
            .iter()
            .map(ToString::to_string)
            .collect::<Vec<_>>()
            .join(", ");
        writeln!(output, "        if (index == {index}) return ({values});")
            .expect("write to string");
    }
    output
}

fn format_solidity(source: &str) -> Result<String, Box<dyn Error>> {
    let forge = env::var_os("FORGE").unwrap_or_else(|| "forge".into());
    let root = root();
    let temporary_path = root
        .join("target")
        .join(format!("oracle-format-{}.sol", std::process::id()));
    fs::create_dir_all(
        temporary_path
            .parent()
            .expect("temporary path has a parent"),
    )?;
    fs::write(&temporary_path, source)?;

    let result = (|| -> Result<String, Box<dyn Error>> {
        let mut previous = source.to_owned();
        for _ in 0..4 {
            let output = Command::new(&forge)
                .arg("fmt")
                .arg(&temporary_path)
                .arg("--root")
                .arg(&root)
                .current_dir(&root)
                .output()
                .map_err(|error| format!("unable to run `forge fmt`: {error}"))?;
            if !output.status.success() {
                return Err(format!(
                    "`forge fmt` failed: {}",
                    String::from_utf8_lossy(&output.stderr).trim()
                )
                .into());
            }
            let formatted = fs::read_to_string(&temporary_path)?;
            if formatted == previous {
                return Ok(formatted);
            }
            previous = formatted;
        }
        Err("`forge fmt` did not converge after four passes".into())
    })();

    let cleanup = fs::remove_file(&temporary_path);
    match (result, cleanup) {
        (Ok(formatted), Ok(())) => Ok(formatted),
        (Ok(_), Err(error)) => Err(error.into()),
        (Err(error), _) => Err(error),
    }
}

fn generated_vectors() -> Result<(String, usize), Box<dyn Error>> {
    let polar_vectors = angle_inputs()
        .into_iter()
        .map(|angle| {
            let radians = from_raw(&angle);
            vec![
                angle,
                to_raw(&radians.clone().cos()),
                to_raw(&radians.sin()),
            ]
        })
        .collect::<Vec<_>>();

    let atan_vectors = atan_inputs()
        .into_iter()
        .map(|input| {
            let y = from_raw(&input[0]);
            let x = from_raw(&input[1]);
            vec![input[0].clone(), input[1].clone(), to_raw(&y.atan2(&x))]
        })
        .collect::<Vec<_>>();

    let magnitude_vectors = magnitude_inputs()
        .into_iter()
        .map(|input| {
            let expected = to_raw(&magnitude(&input[0], &input[1]));
            let tolerance = ceil_ratio(expected.clone().abs() * 2, &unit()) + 4;
            vec![input[0].clone(), input[1].clone(), expected, tolerance]
        })
        .collect::<Vec<_>>();

    let division_vectors = division_inputs()
        .into_iter()
        .map(|input| {
            let (expected_re, expected_im) =
                complex_div(&input[0], &input[1], &input[2], &input[3]);
            if expected_re < min_raw()
                || expected_re > max_raw()
                || expected_im < min_raw()
                || expected_im > max_raw()
            {
                return Err("division oracle result is outside SD59x18");
            }
            Ok(vec![
                input[0].clone(),
                input[1].clone(),
                input[2].clone(),
                input[3].clone(),
                expected_re,
                expected_im,
            ])
        })
        .collect::<Result<Vec<_>, _>>()?;

    let sqrt_vectors = sqrt_inputs()
        .into_iter()
        .map(|input| {
            let (expected_re, expected_im) = complex_sqrt(&input[0], &input[1]);
            let tolerance =
                if input[0].clone().abs() > pow10(59) || input[1].clone().abs() > pow10(59) {
                    integer("1000000000")
                } else {
                    integer("5")
                };
            vec![
                input[0].clone(),
                input[1].clone(),
                expected_re,
                expected_im,
                tolerance,
            ]
        })
        .collect::<Vec<_>>();

    let log_vectors = log_inputs()
        .into_iter()
        .map(|input| {
            let (expected_re, expected_im) = complex_log(&input[0], &input[1]);
            vec![
                input[0].clone(),
                input[1].clone(),
                expected_re,
                expected_im,
                integer("100"),
                integer("1510000000000000"),
            ]
        })
        .collect::<Vec<_>>();

    let exp_vectors = exp_inputs()
        .into_iter()
        .map(|input| {
            let (expected_re, expected_im) = complex_exp(&input[0], &input[1]);
            let scale = maximum_abs(&expected_re, &expected_im);
            let tolerance = ceil_ratio(scale * 482, &integer("100000000")) + 1_000;
            vec![
                input[0].clone(),
                input[1].clone(),
                expected_re,
                expected_im,
                tolerance,
            ]
        })
        .collect::<Vec<_>>();

    let pow_vectors = pow_inputs()
        .into_iter()
        .map(|input| {
            let (expected_re, expected_im) = complex_pow(&input[0], &input[1], &input[2]);
            let scale = maximum_abs(&expected_re, &expected_im);
            let phase_numerator = input[2].clone().abs() * 151 + integer("482000000000000000");
            let tolerance = ceil_ratio(scale * phase_numerator, &pow10(23)) + 1_000;
            vec![
                input[0].clone(),
                input[1].clone(),
                input[2].clone(),
                expected_re,
                expected_im,
                tolerance,
            ]
        })
        .collect::<Vec<_>>();

    let count = polar_vectors.len()
        + atan_vectors.len()
        + magnitude_vectors.len()
        + division_vectors.len()
        + sqrt_vectors.len()
        + log_vectors.len()
        + exp_vectors.len()
        + pow_vectors.len();

    let mut generated = String::from(
        "// SPDX-License-Identifier: MIT\n// This file is generated by tools/oracle.rs. Do not edit manually.\npragma solidity 0.8.36;\n\nlibrary OracleVectors {\n    error IndexOutOfBounds();\n\n",
    );
    macro_rules! group {
        ($name:literal, $signature:literal, $vectors:expr) => {{
            let vectors = &$vectors;
            writeln!(
                generated,
                "    function {}Count() internal pure returns (uint256) {{ return {}; }}",
                $name,
                vectors.len()
            )?;
            writeln!(
                generated,
                "    function {}(uint256 index) internal pure returns ({}) {{",
                $name, $signature
            )?;
            generated.push_str(&return_branches(vectors));
            generated.push_str("        revert IndexOutOfBounds();\n    }\n\n");
        }};
    }

    group!(
        "polar",
        "int256 angle, int256 expectedRe, int256 expectedIm",
        polar_vectors
    );
    group!("atan", "int256 y, int256 x, int256 expected", atan_vectors);
    group!(
        "magnitude",
        "int256 re, int256 im, int256 expected, int256 tolerance",
        magnitude_vectors
    );
    group!(
        "division",
        "int256 aRe, int256 aIm, int256 bRe, int256 bIm, int256 expectedRe, int256 expectedIm",
        division_vectors
    );
    group!(
        "sqrt",
        "int256 re, int256 im, int256 expectedRe, int256 expectedIm, int256 tolerance",
        sqrt_vectors
    );
    group!(
        "log",
        "int256 re, int256 im, int256 expectedRe, int256 expectedIm, int256 reTolerance, int256 imTolerance",
        log_vectors
    );
    group!(
        "exp",
        "int256 re, int256 im, int256 expectedRe, int256 expectedIm, int256 tolerance",
        exp_vectors
    );
    group!(
        "pow",
        "int256 re, int256 im, int256 exponent, int256 expectedRe, int256 expectedIm, int256 tolerance",
        pow_vectors
    );
    generated.truncate(generated.trim_end().len());
    generated.push_str("\n}\n");
    Ok((format_solidity(&generated)?, count))
}

fn root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
}

fn main() -> Result<(), Box<dyn Error>> {
    let write = match env::args().skip(1).collect::<Vec<_>>().as_slice() {
        [] => false,
        [argument] if argument == "--write" => true,
        _ => return Err("usage: cargo run --locked --release --bin oracle -- [--write]".into()),
    };

    let root = root();
    let trig_bound = analyze_trig_table(&root)?;
    let atan_bound = analyze_atan();
    if trig_bound > float(TRIG_ENVELOPE) {
        return Err(format!("trigonometric bound {trig_bound} exceeds {TRIG_ENVELOPE}").into());
    }
    if atan_bound > float(ATAN_ENVELOPE) {
        return Err(format!("atan bound {atan_bound} exceeds {ATAN_ENVELOPE}").into());
    }

    let (generated, vectors) = generated_vectors()?;
    let output_path = root.join("test/fixtures/OracleVectors.sol");
    if write {
        fs::write(&output_path, generated)?;
    } else if fs::read_to_string(&output_path).ok().as_deref() != Some(&generated) {
        return Err(
            "oracle vectors are stale; run `cargo run --locked --release --bin oracle -- --write`"
                .into(),
        );
    }

    println!(
        "{{\"trigAbsoluteErrorBound\":\"{}\",\"atanAbsoluteErrorBound\":\"{}\",\"vectors\":{vectors}}}",
        trig_bound.to_string_radix(10, Some(12)),
        atan_bound.to_string_radix(10, Some(12)),
    );
    Ok(())
}
