/** @type import('hardhat/config').HardhatUserConfig */
require("hardhat-deploy");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("hardhat-abi-exporter");
require("solidity-docgen");
module.exports = {
  solidity: "0.8.15",
  defaultNetwork: "hardhat",
  gasReporter: {
    enabled: true,
  },
};
