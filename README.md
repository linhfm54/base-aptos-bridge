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
```

## Payload Specification

| Bytes | Size | Type | Description |
| :--- | :--- | :--- | :--- |
| `0` | 1 byte | `uint8` | Action ID (1 = Update State) |
| `1-2` | 2 bytes | `uint16` | Message length (Big Endian) |
| `3...` | `Length` bytes | `string` | UTF-8 encoded string |

## Setup & Deployment

### 1. EVM (Base)
```bash
cd evm
npm install
npx hardhat run scripts/deploy.js --network base_sepolia
```

### 2. Aptos
```bash
cd aptos
aptos move publish --profile default
```

### 3. Configuration
```bash
cd evm
npx hardhat run scripts/setPeer.js --network base_sepolia
```
