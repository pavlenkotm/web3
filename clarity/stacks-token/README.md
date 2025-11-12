# 🟠 Clarity Token (Stacks / Bitcoin L2)

A SIP-010 fungible token implementation in Clarity for the Stacks blockchain - a Bitcoin Layer 2 that enables smart contracts secured by Bitcoin.

## 📋 Features

- ✅ SIP-010 standard compliant
- ✅ Transfer functionality
- ✅ Mint and burn capabilities
- ✅ Token metadata (name, symbol, decimals, URI)
- ✅ Decidable and safe by design
- ✅ Bitcoin-secured finality

## 🛠️ Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Clarity runtime packaged as a CLI

```bash
# Install Clarinet (macOS/Linux)
curl -sL https://raw.githubusercontent.com/hirosystems/clarinet/main/install.sh | sh

# Or with Homebrew (macOS)
brew install clarinet

# Verify installation
clarinet --version
```

## 🚀 Quick Start

### Check Contract

```bash
# Check contract syntax and run analysis
clarinet check

# Run static analysis
clarinet analyze
```

### Test Contract

```bash
# Create a test file
cat > tests/token_test.ts << 'EOF'
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Can get token name",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        let wallet_1 = accounts.get('wallet_1')!;
        let block = chain.mineBlock([
            Tx.contractCall('sip-010-token', 'get-name', [], wallet_1.address)
        ]);
        assertEquals(block.receipts[0].result, '(ok "SimpleToken")');
    },
});
EOF

# Run tests
clarinet test
```

### Launch Console

```bash
# Start Clarinet console
clarinet console

# Try commands in the console
>> (contract-call? .sip-010-token get-name)
>> (contract-call? .sip-010-token get-balance tx-sender)
>> (contract-call? .sip-010-token transfer u100 tx-sender 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM none)
```

### Deploy Contract

```bash
# Deploy to testnet
clarinet deployments generate --testnet

# Apply deployment
clarinet deployments apply --testnet

# Deploy to mainnet
clarinet deployments generate --mainnet
clarinet deployments apply --mainnet
```

## 📚 Contract Interface

### Read Functions

- `(get-name)` - Returns token name
- `(get-symbol)` - Returns token symbol
- `(get-decimals)` - Returns token decimals
- `(get-total-supply)` - Returns total supply
- `(get-balance (principal))` - Returns balance of account
- `(get-token-uri)` - Returns token URI

### Write Functions

- `(transfer (amount) (sender) (recipient) (memo))` - Transfer tokens
- `(mint (amount) (recipient))` - Mint new tokens (owner only)
- `(burn (amount) (sender))` - Burn tokens
- `(set-token-uri (uri))` - Set token URI (owner only)

## 🔍 Example Usage

```clarity
;; Transfer 100 tokens
(contract-call? .sip-010-token transfer u100 tx-sender 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM none)

;; Check balance
(contract-call? .sip-010-token get-balance tx-sender)

;; Mint tokens (owner only)
(contract-call? .sip-010-token mint u1000 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## 🧪 Testing

```bash
# Run all tests
clarinet test

# Run with coverage
clarinet test --coverage

# Run specific test
clarinet test tests/token_test.ts
```

## 🔒 Security Features

Clarity provides unique security guarantees:
- **Decidable**: No unbounded loops or recursion
- **No reentrancy**: Post-conditions prevent reentrancy attacks
- **Observable**: All contract behavior is transparent
- **Bitcoin-anchored**: Secured by Bitcoin's PoW

## 🌐 Resources

- [Clarity Language](https://docs.stacks.co/clarity/)
- [SIP-010 Standard](https://github.com/stacksgov/sips/blob/main/sips/sip-010/sip-010-fungible-token-standard.md)
- [Stacks Documentation](https://docs.stacks.co/)
- [Clarinet Documentation](https://github.com/hirosystems/clarinet)

## 📜 License

MIT
