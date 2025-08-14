const fs = require("fs");
const path = require("path");
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deployer:", deployer.address);

  const GBT = await hre.ethers.getContractFactory("GoldBarTether");
  const gbt = await GBT.deploy();
  await gbt.deployed();

  console.log("GoldBarTether deployed to:", gbt.address);

  // Save address to file for easy fetching later
  const out = {
    network: hre.network.name,
    address: gbt.address,
    deployedBy: deployer.address,
    timestamp: Math.floor(Date.now() / 1000)
  };
  const outPath = path.join(process.cwd(), "deployed.json");
  fs.writeFileSync(outPath, JSON.stringify(out, null, 2));
  console.log("Saved deployment info to deployed.json");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
