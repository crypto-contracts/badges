const { ethers, upgrades } = require("hardhat");

async function main() {
  const address = "0xF8BaEB0bBFbAb1D1A7455F695c96c07D88832809";

  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const MintBadge = await ethers.getContractFactory("MintBadge");
  const mintBadge = await upgrades.upgradeProxy(address, MintBadge);

  console.log("Mine upgraded");
}

main();
