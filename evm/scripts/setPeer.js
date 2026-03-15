const hre = require("hardhat");

async function main() {
  const oappAddress = "YOUR_DEPLOYED_BASE_CONTRACT_ADDRESS";
  const aptosModuleAddress = "YOUR_DEPLOYED_APTOS_MODULE_ADDRESS"; // e.g., "0x123abc..."
  const aptosEid = 40108; // LayerZero Endpoint ID for Aptos Testnet

  const OApp = await hre.ethers.getContractAt("AdvancedBaseOApp", oappAddress);

  // Pad Aptos address to 32 bytes for LayerZero V2 standard
  const paddedAptosAddress = hre.ethers.zeroPadValue(aptosModuleAddress, 32);

  const tx = await OApp.setPeer(aptosEid, paddedAptosAddress);
  await tx.wait();

  console.log(`Peer set successfully! Aptos Eid: ${aptosEid}, Padded Address: ${paddedAptosAddress}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
