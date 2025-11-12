# 🔷 Cairo Token Contract (StarkNet)

A simple ERC-20-like token implementation in Cairo for StarkNet, demonstrating the Cairo programming language and StarkNet's Layer 2 scaling solution.

## 📋 Features

- ✅ ERC-20 standard interface
- ✅ Transfer and approve functionality
- ✅ Event emission
- ✅ Safe arithmetic operations
- ✅ Modern Cairo syntax (Cairo 2.x)

## 🛠️ Prerequisites

- [Scarb](https://docs.swmansion.com/scarb/) - Cairo package manager
- [Starkli](https://book.starkli.rs/) - StarkNet CLI tool

```bash
# Install Scarb
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh

# Install Starkli
curl https://get.starkli.sh | sh
starkliup
```

## 🚀 Quick Start

### Build Contract

```bash
# Build the contract
scarb build

# Run tests
scarb test
```

### Deploy to StarkNet

```bash
# Declare the contract
starkli declare target/dev/starknet_token_SimpleToken.sierra.json --network sepolia

# Deploy the contract
starkli deploy <CLASS_HASH> \
  <NAME> \
  <SYMBOL> \
  <DECIMALS> \
  <INITIAL_SUPPLY_LOW> <INITIAL_SUPPLY_HIGH> \
  <RECIPIENT_ADDRESS> \
  --network sepolia
```

## 📚 Contract Interface

### Read Functions

- `get_name()` - Returns token name
- `get_symbol()` - Returns token symbol
- `get_decimals()` - Returns token decimals
- `get_total_supply()` - Returns total supply
- `balance_of(account)` - Returns balance of account
- `allowance(owner, spender)` - Returns allowance

### Write Functions

- `transfer(recipient, amount)` - Transfer tokens
- `transfer_from(sender, recipient, amount)` - Transfer from approved address
- `approve(spender, amount)` - Approve spending

## 🔍 Example Usage

```cairo
// Transfer tokens
token.transfer(recipient_address, 1000_u256);

// Approve spending
token.approve(spender_address, 500_u256);

// Transfer from approved address
token.transfer_from(owner_address, recipient_address, 100_u256);
```

## 🧪 Testing

```bash
# Run all tests
scarb test

# Run with verbosity
scarb test -v
```

## 🌐 Resources

- [Cairo Book](https://book.cairo-lang.org/)
- [StarkNet Documentation](https://docs.starknet.io/)
- [Scarb Documentation](https://docs.swmansion.com/scarb/)

## 📜 License

MIT
