const { expect } = require("chai");
const { parseUnits } = require("ethers/lib/utils");
const { ethers, network } = require("hardhat");
const Complex = require("complex.js");

describe("Deploy Complex", () => {
  let complex;

  beforeEach(async () => {
    const Complex = await ethers.getContractFactory("Complex");
    complex = await Complex.deploy();
  });
  it("Should deploy", async () => {
    await complex.deployed();
    console.log(complex.address);
  });

  it("Should test math", async () => {
    const test = new Complex(2, 2);
    console.log(test);
  });

  it("Should add", async () => {
    const re1 = ethers.utils.parseEther("1");
    const im1 = ethers.utils.parseEther("1");
    const re2 = ethers.utils.parseEther("1");
    const im2 = ethers.utils.parseEther("1");

    const result = await complex.add(re1, im1, re2, im2);
    console.log(result);
  });

  it("Should add", async () => {
    const re1 = ethers.utils.parseEther("1");
    const im1 = ethers.utils.parseEther("1");
    const re2 = ethers.utils.parseEther("1");
    const im2 = ethers.utils.parseEther("1");

    const result = await complex.sub(re1, im1, re2, im2);
    console.log(result);
  });
});
