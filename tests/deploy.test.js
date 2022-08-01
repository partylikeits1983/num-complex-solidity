const { expect } = require("chai");
const { parseUnits } = require("ethers/lib/utils");
const { ethers, network } = require("hardhat");

describe("Deploy Complex", () => {
  it("Should complex library: ", async () => {
    signers = await ethers.getSigners();

    const Complex = await ethers.getContractFactory("Complex");
    const complex = await Complex.deploy();
    await complex.deployed();
    console.log("complex library:", complex.address);
  });

  it("Should get the number of positions of user: ", async () => {});
});
