# 🔵 Motoko Token (DFINITY Internet Computer)

A fungible token implementation in Motoko for the Internet Computer Protocol (ICP), demonstrating DFINITY's native smart contract language.

## 📋 Features

- ✅ ERC-20-like interface
- ✅ Transfer and approval functionality
- ✅ Persistent storage with upgrade hooks
- ✅ Query and update functions
- ✅ Built with Motoko standard library
- ✅ Canister upgrade support

## 🛠️ Prerequisites

- [DFX SDK](https://internetcomputer.org/docs/current/developer-docs/setup/install/) - DFINITY command-line tools

```bash
# Install DFX
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"

# Verify installation
dfx --version
```

## 🚀 Quick Start

### Start Local Replica

```bash
# Start local Internet Computer replica
dfx start --background

# Check status
dfx ping
```

### Deploy Canister

```bash
# Create new identity (first time only)
dfx identity new alice
dfx identity use alice

# Deploy the token canister
dfx deploy

# Get canister ID
dfx canister id token
```

### Interact with Token

```bash
# Get token name
dfx canister call token name

# Get token symbol
dfx canister call token symbol

# Get total supply
dfx canister call token totalSupply

# Mint tokens (for demo purposes)
dfx canister call token mint '(principal "YOUR_PRINCIPAL", 1000000)'

# Check balance
dfx canister call token balanceOf '(principal "YOUR_PRINCIPAL")'

# Transfer tokens
dfx canister call token transfer '(principal "RECIPIENT_PRINCIPAL", 1000)'

# Approve spending
dfx canister call token approve '(principal "SPENDER_PRINCIPAL", 500)'

# Transfer from approved address
dfx canister call token transferFrom '(principal "OWNER", principal "RECIPIENT", 100)'
```

## 📚 Interface

### Query Calls (Fast, No State Change)

- `name() : async Text` - Get token name
- `symbol() : async Text` - Get token symbol
- `decimals() : async Nat8` - Get decimals
- `totalSupply() : async Tokens` - Get total supply
- `balanceOf(account) : async Tokens` - Get balance
- `allowance(owner, spender) : async Tokens` - Get allowance

### Update Calls (State Changing)

- `transfer(to, value) : async TransferResult` - Transfer tokens
- `transferFrom(from, to, value) : async TransferResult` - Transfer from approved
- `approve(spender, value) : async Bool` - Approve spending
- `mint(to, value) : async Bool` - Mint new tokens

## 🔍 Example JavaScript Client

```javascript
import { Actor, HttpAgent } from "@dfinity/agent";
import { idlFactory } from "./declarations/token";

const agent = new HttpAgent({ host: "https://ic0.app" });
const canisterId = "YOUR_CANISTER_ID";
const token = Actor.createActor(idlFactory, { agent, canisterId });

// Get balance
const balance = await token.balanceOf(myPrincipal);

// Transfer tokens
const result = await token.transfer(recipientPrincipal, 1000n);
```

## 🧪 Testing

```bash
# Deploy to local replica
dfx deploy

# Run interactive tests
dfx canister call token name
dfx canister call token totalSupply

# Use Motoko playground for quick tests
# Visit: https://m7sm4-2iaaa-aaaab-qabra-cai.raw.ic0.app/
```

## 📦 Project Structure

```
motoko/icp-token/
├── dfx.json              # DFX configuration
├── src/
│   └── Token.mo          # Main token canister
└── README.md
```

## 🔄 Canister Upgrades

The contract includes upgrade hooks to preserve state:

```motoko
system func preupgrade() {
    // Save state before upgrade
}

system func postupgrade() {
    // Restore state after upgrade
}
```

Upgrade the canister:

```bash
dfx canister install token --mode upgrade
```

## 🌐 Deploy to Mainnet

```bash
# Add cycles to your account (required for mainnet)
dfx ledger account-id
dfx ledger --network ic balance

# Deploy to mainnet
dfx deploy --network ic

# Get canister URL
echo "https://$(dfx canister id token --network ic).ic0.app"
```

## 💡 Motoko Features

- **Actor-based**: Each canister is an actor with async messaging
- **Type-safe**: Strong static typing with inference
- **Orthogonal persistence**: Automatic state management
- **Upgradeable**: Built-in support for canister upgrades

## 🌐 Resources

- [Motoko Documentation](https://internetcomputer.org/docs/current/motoko/main/motoko)
- [Internet Computer Docs](https://internetcomputer.org/docs)
- [DFX CLI Reference](https://internetcomputer.org/docs/current/developer-docs/setup/install/)
- [Motoko Playground](https://m7sm4-2iaaa-aaaab-qabra-cai.raw.ic0.app/)

## 📜 License

MIT
