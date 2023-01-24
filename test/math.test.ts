import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";
import { expect } from "chai";

import Complex from "complex.js";
import { sqrt } from "mathjs";

describe("Complex Number Library", () => {

  async function initialize() {
    const Complex = await ethers.getContractFactory("Num_Complex");
    const complex = await Complex.deploy();

    const a = -1;
    const b = 2;

    const real = ethers.utils.parseEther(a.toString());
    const imag = ethers.utils.parseEther(b.toString());

    return { complex, a, b, real, imag};
  }

  describe("Complex Tests", function () {

/*     it("Should deploy", async () => {
      await complex.deployed();
    });
 */
    it("Should add", async () => {
      const { complex, a, b, real, imag } = await loadFixture(initialize);

      const c1 = new Complex(a, b);
      const c2 = new Complex(a, b);

      const result_js = c1.add(c2);

      const a1 = await complex.wrap(real, imag);
      const b1 = await complex.wrap(real, imag)

      const result_sol = await complex.add(a1, b1);

      const re = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result_sol[0]),
        "ether"
      ));
      const im = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result_sol[1]),
        "ether"
      ));

      expect(result_js.re == re);
      expect(result_js.im == im);
    });

    it("Should subtract", async () => {
      const { complex, a, b, real, imag } = await loadFixture(initialize);

      const c1 = new Complex(a, b);
      const c2 = new Complex(a, b);

      const result_js = c1.sub(c2);

      const a1 = await complex.wrap(real, imag);
      const b1 = await complex.wrap(real, imag)

      const result_sol = await complex.sub(a1, b1);

      const re = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result_sol[0]),
        "ether"
      ));
      const im = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result_sol[1]),
        "ether"
      ));

      expect(result_js.re == re);
      expect(result_js.im == im);
    });

  it("Should multiply", async () => {
    const { complex, a, b, real, imag } = await loadFixture(initialize);

      const c1 = new Complex(a, b);
      const c2 = new Complex(a, b);

      const result_js = c1.mul(c2);

      const a1 = await complex.wrap(real, imag);
      const b1 = await complex.wrap(real, imag)

      const result_sol = await complex.mul(a1, b1);

      const re = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result_sol[0]),
        "ether"
      ));
      const im = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result_sol[1]),
        "ether"
      ));

      expect(result_js.re == re);
      expect(result_js.im == im);
    });

    it("Should divide", async () => {
      const { complex, a, b, real, imag } = await loadFixture(initialize);

      const c1 = new Complex(a, b);
      const c2 = new Complex(a, b);

      const result_js = c1.mul(c2);

      const a1 = await complex.wrap(real, imag);
      const b1 = await complex.wrap(real, imag)

      const result = await complex.div(a1, b1);

      const re = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result[0]),
        "ether"
      ));
      const im = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result[1]),
        "ether"
      ));

      expect(result_js.re == re);
      expect(result_js.im == im);
    });

    it("Should calculate r2", async () => {
      const { complex, a, b } = await loadFixture(initialize);

      const c1 = new Complex(a, b);

      const a1 = c1.re * c1.re;
      const b1 = c1.im * c1.im;

      const result_js = sqrt(a1 + b1);

      const re1 = ethers.utils.parseEther(a.toString());
      const im1 = ethers.utils.parseEther(b.toString());

      const result = await complex.r2(re1, im1);

      const r2 = Number(ethers.utils.formatUnits(ethers.BigNumber.from(result), "ether"));

      expect(result_js == r2);
    });

    it("Should calculate non precise atan2", async () => {
      const { complex, a, b } = await loadFixture(initialize);

      var result_js = Math.atan2(a, b);

      const y = ethers.utils.parseEther(a.toString());
      const x = ethers.utils.parseEther(b.toString());

      const result = await complex.atan2(y, x);

      const atan2 = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result),
        "ether"
      ));

      expect(result_js).to.be.closeTo(atan2, 0.1);
    });

    it("Should calculate precise atan2", async () => {
      const { complex, a, b } = await loadFixture(initialize);

      var result_js = Math.atan2(a, b);

      const y = ethers.utils.parseEther(a.toString());
      const x = ethers.utils.parseEther(b.toString());

      const result = await complex.p_atan2(y, x);

      const atan2 = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result),
        "ether"
      ));

      expect(result_js).to.be.closeTo(atan2, 0.01);
    });

    it("Should calculate more precise atan2 (1 to 1)", async () => {
      const { complex } = await loadFixture(initialize);

      var input = 2 / 3;

      var result_js = Math.atan2(2, 3);

      var sol_input = ethers.utils.parseEther(input.toString());

      const result = await complex.atan1to1(sol_input);

      const atan2 = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result),
        "ether"
      ));

      expect(result_js).to.be.closeTo(atan2, 0.001);
    });

    it("Should calculate complex ln", async () => {
      const { complex, a, b, real, imag } = await loadFixture(initialize);

      const c = new Complex(a, b);

      const result_js = c.log();

      const a1 = await complex.wrap(real, imag);

      const result_sol = await complex.ln(a1);


      const re = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result_sol[0]),
        "ether"
      ));
      const im = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result_sol[1]),
        "ether"
      ));

      expect(result_js.re).to.be.closeTo(re, 0.005);
      expect(result_js.im).to.be.closeTo(im, 0.005);
    });

    it("Should calculate complex sqrt", async () => {
      const { complex, a, b, real, imag } = await loadFixture(initialize);

      const c = new Complex(a, b);

      const result_js = c.sqrt();

      const a1 = await complex.wrap(real, imag);

      const result_sol = await complex.sqrt(a1);

      const re = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result_sol[0]),
        "ether"
      ));
      const im = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result_sol[1]),
        "ether"
      ));

      expect(result_js.re).to.be.closeTo(re, 0.003);
      expect(result_js.im).to.be.closeTo(im, 0.003);
    });

    it("Should calculate complex exponential", async () => {
      const { complex, a, b, real, imag } = await loadFixture(initialize);

      const c = new Complex(a, b);

      const result_js = c.exp();

      const a1 = await complex.wrap(real, imag);

      const result_sol = await complex.exp(a1);

      const re = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result_sol[0]),
        "ether"
      ));
      const im = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result_sol[1]),
        "ether"
      ));

      expect(result_js.re).to.be.closeTo(re, 0.000001);
      expect(result_js.im).to.be.closeTo(im, 0.000001);
    });

    it("Should calculate complex power", async () => {
      const { complex, a, b, real, imag } = await loadFixture(initialize);

      const c = new Complex(a, b);

      const result_js = c.pow(2);

      const a1 = await complex.wrap(real, imag);

      const n = ethers.utils.parseEther("2");

      const result_sol = await complex.pow(a1, n);

      const re = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result_sol[0]),
        "ether"
      ));
      const im = Number(ethers.utils.formatUnits(
        ethers.BigNumber.from(result_sol[1]),
        "ether"
      ));

      expect(result_js.re).to.be.closeTo(re, 0.02);
      expect(result_js.im).to.be.closeTo(im, 0.02);
    });
  });
  
});
