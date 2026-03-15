# base-aptos-bridge
# 🌉 Omnichain Base-to-Aptos Bridge (LayerZero V2)

Production-grade cross-chain dApp enabling secure message and state transfers from Base (EVM) to Aptos (Move) using LayerZero V2 OApp architecture.

## Architecture

```mermaid
sequenceDiagram
    participant User
    participant Base Contract (EVM)
    participant LayerZero Endpoint (Base)
    participant DVN & Executor
    participant LayerZero Endpoint (Aptos)
    participant Aptos Module (Move)

    User->>Base Contract (EVM): sendCrossChainMessage(dstEid, message)
    Base Contract (EVM)->>Base Contract (EVM): encodePacked(Action, Length, Message)
    Base Contract (EVM)->>LayerZero Endpoint (Base): _lzSend(payload, options)
    LayerZero Endpoint (Base)->>DVN & Executor: emit Packet()
    DVN & Executor->>LayerZero Endpoint (Aptos): Verify & Execute
    LayerZero Endpoint (Aptos)->>Aptos Module (Move): lz_receive(payload)
    Aptos Module (Move)->>Aptos Module (Move): decode Custom Bytes
    Aptos Module (Move)->>Aptos Module (Move): processAction()
Payload SpecificationBytesSizeTypeDescription01 byteuint8Action ID (1 = Update State)1-22 bytesuint16Message length (Big Endian)3...Length bytesstringUTF-8 encoded stringSetup & DeploymentEVM (Base)Bashcd evm
npm install
npx hardhat run scripts/deploy.js --network base_sepolia
AptosBashcd aptos
aptos move publish --profile default
ConfigurationBashcd evm
npx hardhat run scripts/setPeer.js --network base_sepolia
