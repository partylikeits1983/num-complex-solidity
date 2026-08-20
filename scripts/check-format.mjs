import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(scriptDirectory, "..");
const sourceFiles = [];

function collectSolidityFiles(directory) {
    for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
        const entryPath = path.join(directory, entry.name);
        if (entry.isDirectory()) collectSolidityFiles(entryPath);
        else if (entry.name.endsWith(".sol") && entryPath !== path.join(root, "test", "fixtures", "OracleVectors.sol")) {
            sourceFiles.push(path.relative(root, entryPath));
        }
    }
}

collectSolidityFiles(path.join(root, "contracts"));
collectSolidityFiles(path.join(root, "test"));
sourceFiles.sort();
execFileSync("forge", ["fmt", "--check", ...sourceFiles], { cwd: root, stdio: "inherit" });
