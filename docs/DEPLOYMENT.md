# Deployment Guide

## Prerequisites

- Node.js 18+
- Hardhat
- Ethereum wallet with testnet/mainnet ETH
- Infura/Alchemy API key

## Environment Setup

Create `.env`:

```bash
PRIVATE_KEY=your_private_key_here
SEPOLIA_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY
MAINNET_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY
ETHERSCAN_API_KEY=your_etherscan_key
```

## Deploy to Sepolia

```bash
npm run deploy:sepolia
```

## Deploy to Mainnet

```bash
npm run deploy:mainnet
```

## Verify Contracts

```bash
npx hardhat verify --network sepolia CONTRACT_ADDRESS
```
