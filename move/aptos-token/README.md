# Move Token on Aptos

Fungible token smart contract built with Move language for the Aptos blockchain.

## Features

- **Resource-Oriented**: Move's unique resource model
- **Type Safety**: Strong type system with generics
- **Formal Verification**: Built for provable correctness
- **Token Operations**: Mint, transfer, burn
- **Access Control**: Owner-only minting
- **Aptos Framework**: Integration with Aptos Coin standard

## Why Move?

- **Safety**: Resources can't be copied or lost
- **Flexibility**: Generic programming with type parameters
- **Verification**: Designed for formal verification
- **Performance**: Compiled to Move bytecode
- **Security**: No reentrancy, no unexpected state changes

## Tech Stack

- **Move**: Resource-oriented programming language
- **Aptos**: Layer-1 blockchain
- **Aptos CLI**: Command-line tools
- **Aptos Framework**: Standard library

## Prerequisites

```bash
# Install Aptos CLI
curl -fsSL "https://aptos.dev/scripts/install_cli.py" | python3

# Verify installation
aptos --version
```

## Project Setup

```bash
cd move/aptos-token

# Initialize Aptos account
aptos init

# Update dependencies
aptos move compile
```

## Compilation

### Compile Contract

```bash
aptos move compile
```

Output:
```
Compiling, may take a little while to download git dependencies...
INCLUDING DEPENDENCY AptosFramework
BUILDING AptosToken
Success!
```

### Run Tests

```bash
aptos move test
```

### Publish Module

```bash
# Publish to testnet
aptos move publish --named-addresses token_addr=default

# Publish to mainnet
aptos move publish --named-addresses token_addr=default --network mainnet
```

## Usage

### Initialize Token

```bash
aptos move run \
  --function-id 'default::simple_token::initialize' \
  --args string:"MyToken" string:"MTK" u8:8 bool:true
```

### Mint Tokens

```bash
aptos move run \
  --function-id 'default::simple_token::mint' \
  --args address:0x123...recipient u64:1000000
```

### Transfer Tokens

```bash
aptos move run \
  --function-id 'default::simple_token::transfer' \
  --args address:0x123...recipient u64:500
```

### Burn Tokens

```bash
aptos move run \
  --function-id 'default::simple_token::burn' \
  --args u64:100
```

### Query Balance

```bash
aptos move view \
  --function-id 'default::simple_token::balance' \
  --args address:0x123...account
```

## TypeScript SDK Integration

### Install SDK

```bash
npm install @aptos-labs/ts-sdk
```

### Initialize Client

```typescript
import { Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";

const config = new AptosConfig({ network: Network.TESTNET });
const aptos = new Aptos(config);
```

### Call Functions

```typescript
// Initialize token
const initTx = await aptos.transaction.build.simple({
  sender: account.accountAddress,
  data: {
    function: `${moduleAddress}::simple_token::initialize`,
    typeArguments: [],
    functionArguments: ["MyToken", "MTK", 8, true],
  },
});

const committedTx = await aptos.signAndSubmitTransaction({
  signer: account,
  transaction: initTx,
});

await aptos.waitForTransaction({ transactionHash: committedTx.hash });

// Mint tokens
const mintTx = await aptos.transaction.build.simple({
  sender: account.accountAddress,
  data: {
    function: `${moduleAddress}::simple_token::mint`,
    functionArguments: [recipient, 1000000],
  },
});

// Transfer tokens
const transferTx = await aptos.transaction.build.simple({
  sender: account.accountAddress,
  data: {
    function: `${moduleAddress}::simple_token::transfer`,
    functionArguments: [recipient, 500],
  },
});
```

### Query Data

```typescript
// Get balance
const balance = await aptos.view({
  payload: {
    function: `${moduleAddress}::simple_token::balance`,
    functionArguments: [accountAddress],
  },
});

console.log(`Balance: ${balance[0]}`);
```

## Move Language Features

### Resources

```move
struct Capabilities<phantom CoinType> has key {
    mint_cap: MintCapability<CoinType>,
    burn_cap: BurnCapability<CoinType>,
}
```

Resources (`has key`):
- Stored under accounts
- Cannot be copied or dropped
- Must be explicitly moved

### Generics

```move
public fun balance<CoinType>(account: address): u64 {
    coin::balance<CoinType>(account)
}
```

Type parameters enable reusable code.

### Abilities

```move
struct TokenInfo has key {  // Can be stored
    name: String,
}

struct SimpleToken {}  // Marker type (no abilities needed)
```

Abilities control what operations are allowed:
- `copy`: Value can be copied
- `drop`: Value can be dropped
- `store`: Value can be stored in global storage
- `key`: Value can be used as a key for global storage

### Acquires

```move
public fun burn(account: &signer, amount: u64) acquires Capabilities {
    let caps = borrow_global<Capabilities<SimpleToken>>(addr);
    // ...
}
```

Functions that access global storage must declare `acquires`.

## Testing

### Unit Tests

```move
#[test(owner = @0x1)]
public fun test_initialize(owner: &signer) {
    initialize(owner, b"Test Token", b"TEST", 8, true);
    assert!(exists<TokenInfo>(signer::address_of(owner)), 0);
}
```

Run tests:
```bash
aptos move test
```

### Integration Tests

```bash
# Test on local testnet
aptos node run-local-testnet --with-faucet

# In another terminal
aptos move test --dev
```

## Security Considerations

### Resource Safety

Move's type system prevents:
- **Duplication**: Resources can't be copied
- **Loss**: Resources can't be dropped (must be explicitly moved or destroyed)
- **Reuse**: Resources are linear types

### Access Control

```move
assert!(token_info.owner == owner_addr, E_NOT_OWNER);
```

Always verify permissions before operations.

### Formal Verification

Move supports formal verification using the Move Prover:

```bash
aptos move prove
```

## Project Structure

```
move/aptos-token/
├── sources/
│   └── token.move        # Main contract
├── tests/
│   └── token_tests.move  # Test modules
├── Move.toml             # Package manifest
└── README.md
```

## Common Commands

```bash
# Compile
aptos move compile

# Test
aptos move test

# Publish
aptos move publish

# Run function
aptos move run --function-id <FUNCTION>

# View function (read-only)
aptos move view --function-id <FUNCTION>

# Prove (formal verification)
aptos move prove
```

## Move vs Other Languages

| Feature | Move | Solidity | Rust |
|---------|------|----------|------|
| Resources | ✅ Native | ❌ No | ⚠️ Lifetime system |
| Type Safety | ✅ Very strong | ⚠️ Moderate | ✅ Very strong |
| Generics | ✅ Yes | ❌ No | ✅ Yes |
| Formal Verification | ✅ Built-in | ⚠️ External tools | ⚠️ External tools |
| Reentrancy | ✅ Prevented | ⚠️ Manual checks | ⚠️ Manual checks |

## Performance

- **Transaction Speed**: ~160,000 TPS (theoretical)
- **Block Time**: Sub-second finality
- **Transaction Cost**: Very low (<$0.01)
- **Parallel Execution**: Block-STM algorithm

## Resources

- [Move Language Book](https://move-language.github.io/move/)
- [Aptos Documentation](https://aptos.dev/)
- [Move on Aptos](https://aptos.dev/move/move-on-aptos)
- [Aptos TypeScript SDK](https://aptos.dev/sdks/ts-sdk/)
- [Move Prover](https://github.com/move-language/move/tree/main/language/move-prover)

## License

MIT
