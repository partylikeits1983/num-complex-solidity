import { ethers } from "hardhat";

describe("Deploy Num_Complex", () => {
	it("Should complex library: ", async () => {
		const Complex = await ethers.getContractFactory("Num_Complex");
		const complex = await Complex.deploy();
		await complex.deployed();
		console.log("complex library:", complex.address);
	});
});
