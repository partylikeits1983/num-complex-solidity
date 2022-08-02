const { expect, assert } = require("chai");
const should = require("should");
const { parseUnits } = require("ethers/lib/utils");
const { ethers, network } = require("hardhat");
const Complex = require("complex.js");
const { sqrt } = require("mathjs");

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

  it("Should test complex.js", async () => {
    const test = new Complex(1, 2);
    console.log(test);
  });

  it("Should add", async () => {
    const c1 = new Complex(1, 2);
    const c2 = new Complex(1, 2);

    const result_js = c1.add(c2);

    const re1 = ethers.utils.parseEther("1");
    const im1 = ethers.utils.parseEther("2");
    const re2 = ethers.utils.parseEther("1");
    const im2 = ethers.utils.parseEther("2");

    const result = await complex.add(re1, im1, re2, im2);

    const re = ethers.utils.formatUnits(
      ethers.BigNumber.from(result[0]),
      "ether"
    );
    const im = ethers.utils.formatUnits(
      ethers.BigNumber.from(result[1]),
      "ether"
    );

    expect(result_js.re == re);
    expect(result_js.im == im);
  });

  it("Should subtract", async () => {
    const c1 = new Complex(1, 2);
    const c2 = new Complex(1, 2);

    const result_js = c1.sub(c2);

    const re1 = ethers.utils.parseEther("1");
    const im1 = ethers.utils.parseEther("2");
    const re2 = ethers.utils.parseEther("1");
    const im2 = ethers.utils.parseEther("2");

    const result = await complex.sub(re1, im1, re2, im2);

    const re = ethers.utils.formatUnits(
      ethers.BigNumber.from(result[0]),
      "ether"
    );
    const im = ethers.utils.formatUnits(
      ethers.BigNumber.from(result[1]),
      "ether"
    );

    expect(result_js.re == re);
    expect(result_js.im == im);
  });

  it("Should multiply", async () => {
    const c1 = new Complex(1, 2);
    const c2 = new Complex(1, 2);

    const result_js = c1.mul(c2);

    const re1 = ethers.utils.parseEther("1");
    const im1 = ethers.utils.parseEther("2");
    const re2 = ethers.utils.parseEther("1");
    const im2 = ethers.utils.parseEther("2");

    const result = await complex.mul(re1, im1, re2, im2);

    const re = ethers.utils.formatUnits(
      ethers.BigNumber.from(result[0]),
      "ether"
    );
    const im = ethers.utils.formatUnits(
      ethers.BigNumber.from(result[1]),
      "ether"
    );

    expect(result_js.re == re);
    expect(result_js.im == im);
  });

  it("Should divide", async () => {
    const c1 = new Complex(1, 2);
    const c2 = new Complex(1, 2);

    const result_js = c1.div(c2);

    const re1 = ethers.utils.parseEther("1");
    const im1 = ethers.utils.parseEther("2");
    const re2 = ethers.utils.parseEther("1");
    const im2 = ethers.utils.parseEther("2");

    const result = await complex.div(re1, im1, re2, im2);

    const re = ethers.utils.formatUnits(
      ethers.BigNumber.from(result[0]),
      "ether"
    );
    const im = ethers.utils.formatUnits(
      ethers.BigNumber.from(result[1]),
      "ether"
    );

    expect(result_js.re == re);
    expect(result_js.im == im);
  });

  it("Should calculate r2", async () => {
    const c1 = new Complex(1, 2);

    const a = c1.re * c1.re;
    const b = c1.im * c1.im;

    const result_js = sqrt(a + b);

    const re1 = ethers.utils.parseEther("1");
    const im1 = ethers.utils.parseEther("2");

    const result = await complex.r2(re1, im1);

    const r2 = ethers.utils.formatUnits(ethers.BigNumber.from(result), "ether");

    expect(result_js == r2);
  });

  it("Should calculate non precise atan2", async () => {
    var result_js = Math.atan2(1, 2);

    var y = ethers.utils.parseEther("1");
    var x = ethers.utils.parseEther("2");

    const result = await complex.atan2(y, x);

    const atan2 = ethers.utils.formatUnits(
      ethers.BigNumber.from(result),
      "ether"
    );

    expect(result_js).to.be.closeTo(parseFloat(atan2), 0.1);
  });

  it("Should calculate precise atan2", async () => {
    var result_js = Math.atan2(1, 2);

    var y = ethers.utils.parseEther("1");
    var x = ethers.utils.parseEther("2");

    const result = await complex.p_atan2(y, x);

    const atan2 = ethers.utils.formatUnits(
      ethers.BigNumber.from(result),
      "ether"
    );

    expect(result_js).to.be.closeTo(parseFloat(atan2), 0.01);
  });

  it("Should calculate more precise atan2 (1 to 1)", async () => {
    var input = 2 / 3;

    var result_js = Math.atan2(2, 3);

    var sol_input = ethers.utils.parseEther(input.toString());

    const result = await complex.atan1to1(sol_input);

    const atan2 = ethers.utils.formatUnits(
      ethers.BigNumber.from(result),
      "ether"
    );

    expect(result_js).to.be.closeTo(parseFloat(atan2), 0.001);
  });

  it("Should calculate complex ln", async () => {
    const c = new Complex(1, 2);

    const result_js = c.log();

    const re1 = ethers.utils.parseEther("1");
    const im1 = ethers.utils.parseEther("2");

    const result = await complex.complexLN(re1, im1);

    const re = ethers.utils.formatUnits(
      ethers.BigNumber.from(result[0]),
      "ether"
    );
    const im = ethers.utils.formatUnits(
      ethers.BigNumber.from(result[1]),
      "ether"
    );

    expect(result_js.re).to.be.closeTo(parseFloat(re), 0.02);
    expect(result_js.im).to.be.closeTo(parseFloat(im), 0.02);
  });

  it("Should calculate complex sqrt", async () => {
    const c = new Complex(1, 2);

    const result_js = c.sqrt();

    const re1 = ethers.utils.parseEther("1");
    const im1 = ethers.utils.parseEther("2");

    const result = await complex.complexSQRT(re1, im1);

    const re = ethers.utils.formatUnits(
      ethers.BigNumber.from(result[0]),
      "ether"
    );
    const im = ethers.utils.formatUnits(
      ethers.BigNumber.from(result[1]),
      "ether"
    );

    expect(result_js.re).to.be.closeTo(parseFloat(re), 0.1);
    expect(result_js.im).to.be.closeTo(parseFloat(im), 0.1);
  });
});
