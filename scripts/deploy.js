const { ethers, upgrades } = require("hardhat");

async function main() {
  const badge = "0xd1ebdffab1b4e9f36009101674a46876f83c1692";

  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const MintBadge = await ethers.getContractFactory("MintBadge");
  const mintBadge = await upgrades.deployProxy(MintBadge, [badge]);
  await mintBadge.deployed();

  console.log("mintBadge deployed to:", mintBadge.address);
}

main();
