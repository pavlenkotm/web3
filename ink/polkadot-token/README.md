# 🟣 Ink! ERC-20 Token (Polkadot/Substrate)

A standard ERC-20 token implementation using Ink! smart contract language for Polkadot parachains and Substrate-based blockchains.

## 📋 Features

- ✅ Full ERC-20 standard implementation
- ✅ Transfer and approve functionality
- ✅ Event emission (Transfer, Approval)
- ✅ Safe arithmetic operations
- ✅ Built with Ink! 5.0
- ✅ Unit tests included

## 🛠️ Prerequisites

- [Rust](https://rustup.rs/) - Rust toolchain
- [cargo-contract](https://github.com/paritytech/cargo-contract) - Ink! contract CLI

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install cargo-contract
cargo install cargo-contract --force

# Add WebAssembly target
rustup target add wasm32-unknown-unknown
```

## 🚀 Quick Start

### Build Contract

```bash
# Build the contract
cargo contract build

# Build with optimization
cargo contract build --release
```

### Test Contract

```bash
# Run tests
cargo test

# Run tests with output
cargo test -- --nocapture
```

### Deploy Contract

```bash
# Start local node (in separate terminal)
substrate-contracts-node --dev

# Deploy to local node
cargo contract instantiate \
  --constructor new \
  --args 1000000 \
  --suri //Alice \
  --execute

# Deploy to testnet
cargo contract instantiate \
  --constructor new \
  --args 1000000 \
  --url wss://rococo-contracts-rpc.polkadot.io \
  --suri "your seed phrase" \
  --execute
```

## 📚 Contract Interface

### Read Functions

- `total_supply()` - Returns total supply
- `balance_of(owner)` - Returns balance of account
- `allowance(owner, spender)` - Returns allowance

### Write Functions

- `transfer(to, value)` - Transfer tokens
- `transfer_from(from, to, value)` - Transfer from approved address
- `approve(spender, value)` - Approve spending

## 🔍 Example Usage

```rust
// Transfer tokens
token.transfer(recipient, 1000)?;

// Approve spending
token.approve(spender, 500)?;

// Transfer from approved address
token.transfer_from(owner, recipient, 100)?;
```

## 🧪 Testing

```bash
# Run all tests
cargo test

# Run with code coverage
cargo tarpaulin --ignore-tests
```

## 📦 Build Artifacts

After building, you'll find:
- `target/ink/erc20.contract` - Contract bundle (metadata + Wasm)
- `target/ink/erc20.wasm` - Contract code
- `target/ink/metadata.json` - Contract metadata

## 🌐 Resources

- [Ink! Documentation](https://use.ink/)
- [Polkadot Docs](https://docs.polkadot.network/)
- [Substrate Contracts](https://github.com/paritytech/substrate-contracts-node)

## 📜 License

MIT
