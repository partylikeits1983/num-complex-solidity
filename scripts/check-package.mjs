import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(scriptDirectory, "..");
const temporaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), "num-complex-package-"));

try {
    const packOutput = execFileSync("npm", ["pack", "--json", "--pack-destination", temporaryRoot], {
        cwd: root,
        encoding: "utf8",
    });
    const [{ filename, files }] = JSON.parse(packOutput);
    const paths = files.map((file) => file.path).sort();
    const expectedPaths = [
        "LICENSE",
        "README.md",
        "contracts/Complex.sol",
        "contracts/Trigonometry.sol",
        "docs/accuracy.md",
        "docs/index.md",
        "docs/modernization.md",
        "docs/security-review.md",
        "package.json",
    ];
    if (JSON.stringify(paths) !== JSON.stringify(expectedPaths)) {
        throw new Error(`Unexpected package contents: ${JSON.stringify(paths)}`);
    }

    execFileSync(
        "npm",
        ["install", "--ignore-scripts", "--no-audit", "--no-fund", "--package-lock=false", path.join(temporaryRoot, filename)],
        { cwd: temporaryRoot, stdio: "inherit" },
    );

    fs.mkdirSync(path.join(temporaryRoot, "src"));
    fs.writeFileSync(
        path.join(temporaryRoot, "foundry.toml"),
        `[profile.default]\nsrc = "src"\nlibs = ["node_modules"]\nsolc_version = "0.8.36"\n`,
    );
    fs.writeFileSync(
        path.join(temporaryRoot, "remappings.txt"),
        "@prb/math/=node_modules/@prb/math/\nnum_complex_solidity/=node_modules/num_complex_solidity/\n",
    );
    fs.writeFileSync(
        path.join(temporaryRoot, "src", "Consumer.sol"),
        `// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import { sd } from "@prb/math/src/SD59x18.sol";
import { Complex, ComplexMath } from "num_complex_solidity/contracts/Complex.sol";

contract Consumer {
    using ComplexMath for Complex;

    function square(int256 re, int256 im) external pure returns (int256, int256) {
        Complex memory result = ComplexMath.complex(sd(re), sd(im)).square();
        return (result.re.unwrap(), result.im.unwrap());
    }
}
`,
    );

    execFileSync("forge", ["build", "--root", temporaryRoot], { cwd: temporaryRoot, stdio: "inherit" });
    console.log(JSON.stringify({ package: filename, files: paths.length, downstreamBuild: "passed" }));
} finally {
    fs.rmSync(temporaryRoot, { force: true, recursive: true });
}
