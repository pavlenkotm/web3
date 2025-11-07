# Rust Solana Token Program

High-performance Solana smart contract (program) built with Anchor framework for SPL token operations.

## Features

- **Token Minting**: Create new tokens with mint authority
- **Token Transfers**: Transfer tokens between accounts
- **Token Burning**: Burn tokens to reduce supply
- **Authority Management**: Secure access control
- **Anchor Framework**: Type-safe Solana development
- **SPL Token Integration**: Standard token program CPI calls

## Tech Stack

- **Rust**: Systems programming language
- **Anchor**: Solana development framework
- **Solana**: High-performance blockchain
- **SPL Token**: Solana token standard
- **Cargo**: Rust package manager

## Prerequisites

- Rust 1.75+
- Solana CLI 1.18+
- Anchor 0.29+
- Node.js 18+ (for tests)

## Installation

### Install Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Install Solana

```bash
sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
```

### Install Anchor

```bash
cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
avm install latest
avm use latest
```

### Setup Project

```bash
cd rust/solana-token-program
anchor build
```

## Usage

### Build Program

```bash
anchor build
```

This generates:
- Program binary: `target/deploy/token_program.so`
- IDL: `target/idl/token_program.json`
- TypeScript types: `target/types/token_program.ts`

### Deploy to Localnet

```bash
# Start local validator
solana-test-validator

# In another terminal
anchor deploy
```

### Deploy to Devnet

```bash
solana config set --url devnet
anchor deploy --provider.cluster devnet
```

### Run Tests

```bash
anchor test
```

## Program Instructions

### 1. Initialize Mint

Creates a new token mint.

```rust
pub fn initialize_mint(
    ctx: Context<InitializeMint>,
    decimals: u8,
) -> Result<()>
```

**Accounts:**
- `mint`: New mint account (PDA)
- `authority`: Mint authority (signer)
- `token_program`: SPL Token program
- `system_program`: System program
- `rent`: Rent sysvar

### 2. Mint Tokens

Mints new tokens to an account.

```rust
pub fn mint_tokens(
    ctx: Context<MintTokens>,
    amount: u64,
) -> Result<()>
```

**Accounts:**
- `mint`: Token mint
- `token_account`: Destination token account
- `authority`: Mint authority (signer)
- `token_program`: SPL Token program

### 3. Transfer Tokens

Transfers tokens between accounts.

```rust
pub fn transfer_tokens(
    ctx: Context<TransferTokens>,
    amount: u64,
) -> Result<()>
```

**Accounts:**
- `from`: Source token account
- `to`: Destination token account
- `authority`: Transfer authority (signer)
- `token_program`: SPL Token program

### 4. Burn Tokens

Burns tokens to reduce supply.

```rust
pub fn burn_tokens(
    ctx: Context<BurnTokens>,
    amount: u64,
) -> Result<()>
```

**Accounts:**
- `mint`: Token mint
- `token_account`: Token account to burn from
- `authority`: Burn authority (signer)
- `token_program`: SPL Token program

## Client Integration

### TypeScript Example

```typescript
import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { TokenProgram } from "../target/types/token_program";

const provider = anchor.AnchorProvider.env();
anchor.setProvider(provider);

const program = anchor.workspace.TokenProgram as Program<TokenProgram>;

// Initialize mint
const mintKeypair = anchor.web3.Keypair.generate();
await program.methods
  .initializeMint(9)
  .accounts({
    mint: mintKeypair.publicKey,
    authority: provider.wallet.publicKey,
  })
  .signers([mintKeypair])
  .rpc();

// Mint tokens
await program.methods
  .mintTokens(new anchor.BN(1000000))
  .accounts({
    mint: mintKeypair.publicKey,
    tokenAccount: tokenAccount,
    authority: provider.wallet.publicKey,
  })
  .rpc();
```

### Rust Client Example

```rust
use anchor_client::solana_sdk::signature::Keypair;
use anchor_client::Client;

let payer = Keypair::new();
let client = Client::new_with_options(cluster, payer, commitment);
let program = client.program(program_id);

// Call mint_tokens
program
    .request()
    .accounts(token_program::accounts::MintTokens {
        mint: mint_pubkey,
        token_account: token_account_pubkey,
        authority: authority_pubkey,
        token_program: spl_token::id(),
    })
    .args(token_program::instruction::MintTokens {
        amount: 1_000_000,
    })
    .send()?;
```

## Project Structure

```
rust/solana-token-program/
├── programs/
│   └── token-program/
│       ├── src/
│       │   └── lib.rs          # Main program logic
│       ├── Cargo.toml          # Dependencies
│       └── Xargo.toml          # Cross-compilation
├── tests/
│   └── token-program.ts        # TypeScript tests
├── Anchor.toml                 # Anchor config
├── Cargo.toml                  # Workspace config
└── README.md
```

## Security Considerations

### Access Control

```rust
#[account(
    mut,
    constraint = mint.mint_authority == COption::Some(authority.key())
        @ TokenError::InvalidMintAuthority
)]
pub mint: Account<'info, Mint>,
```

### Account Validation

Anchor automatically validates:
- Account ownership
- Account discriminators
- PDA derivation
- Signer requirements

### Best Practices

1. **Use PDAs**: For program-controlled accounts
2. **Validate Authorities**: Check mint/freeze authorities
3. **Check Balances**: Verify sufficient funds
4. **Reuse Accounts**: Minimize account creation costs
5. **Handle Errors**: Use custom error codes

## Testing

### Unit Tests

```bash
cargo test-bpf
```

### Integration Tests

```bash
anchor test
```

### Test Coverage

```bash
cargo tarpaulin --out Html
```

## Performance

- **Transaction Speed**: ~50,000 TPS (Solana)
- **Block Time**: ~400ms
- **Transaction Cost**: ~0.00025 SOL
- **Program Size**: ~50KB compiled

## Common Commands

```bash
# Build program
anchor build

# Test program
anchor test

# Deploy program
anchor deploy

# Generate IDL
anchor idl init <PROGRAM_ID>

# Upgrade program
anchor upgrade target/deploy/token_program.so --program-id <PROGRAM_ID>

# Show program logs
solana logs <PROGRAM_ID>
```

## Troubleshooting

### Program Build Fails

```bash
cargo clean
anchor clean
anchor build
```

### Deploy Fails

```bash
# Increase priority fee
solana config set --commitment confirmed
anchor deploy --provider.cluster devnet
```

### Account Not Found

```bash
# Ensure accounts are initialized
solana account <ACCOUNT_PUBKEY>
```

## Resources

- [Anchor Documentation](https://www.anchor-lang.com/)
- [Solana Documentation](https://docs.solana.com/)
- [SPL Token Program](https://spl.solana.com/token)
- [Rust Book](https://doc.rust-lang.org/book/)

## License

MIT
