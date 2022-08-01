const { expect } = require("chai");
const { parseUnits } = require("ethers/lib/utils");
const { ethers, network } = require("hardhat");

describe("Deploy Complex", () => {
  let complex;

  beforeEach(async () => {
    const Complex = await ethers.getContractFactory("Complex");
    const complex = await Complex.deploy();
  });
  it("Should complex library: ", async () => {
    await complex.deployed();

    const tx = await complex.add(1, 1, 1, 1);
    console.log(tx);
  });

  it("Should add: ", async () => {
    const tx = await complex.add(1, 1, 1, 1);
    console.log(tx);
  });
});
