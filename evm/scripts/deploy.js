const hre = require("hardhat");

async function main() {
  const endpointV2 = "0x6EDCE65403992e310A62460808c4b910D972f10f"; // Base Sepolia LZ Endpoint
  const delegate = (await hre.ethers.getSigners())[0].address;

  const OApp = await hre.ethers.getContractFactory("AdvancedBaseOApp");
  const oapp = await OApp.deploy(endpointV2, delegate);
  await oapp.waitForDeployment();

  console.log(`AdvancedBaseOApp deployed to: ${await oapp.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
