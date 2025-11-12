# 🔴 Plutus Smart Contract (Cardano)

A simple token validator implementation in Plutus using Haskell for the Cardano blockchain, demonstrating UTXO-based smart contracts.

## 📋 Features

- ✅ Token transfer functionality
- ✅ Approve and transferFrom mechanism
- ✅ Minting capability (owner only)
- ✅ UTXO-based validation
- ✅ Type-safe with Haskell
- ✅ Plutus V2 implementation

## 🛠️ Prerequisites

- [GHC](https://www.haskell.org/ghc/) - Glasgow Haskell Compiler (9.2+)
- [Cabal](https://www.haskell.org/cabal/) - Haskell build tool
- [Cardano Node](https://github.com/input-output-hk/cardano-node) - Cardano blockchain node
- [Plutus](https://github.com/input-output-hk/plutus) - Plutus platform

```bash
# Install GHCup (Haskell toolchain installer)
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

# Install required versions
ghcup install ghc 9.2.8
ghcup install cabal 3.8.1.0
ghcup set ghc 9.2.8

# Verify installation
ghc --version
cabal --version
```

## 🚀 Quick Start

### Build Project

```bash
# Update Cabal package list
cabal update

# Build the project
cabal build

# Enter REPL
cabal repl
```

### Compile Plutus Script

```haskell
-- In GHCi REPL
:load SimpleToken

-- Define token parameters
let params = TokenParams
      { tpTokenName = "MyToken"
      , tpSymbol = "MTK"
      , tpDecimals = 8
      , tpOwner = "your-pub-key-hash"
      }

-- Get validator script
let validator = tokenValidator params

-- Serialize for blockchain
let script = tokenScriptShortBs params
```

### Deploy to Cardano

```bash
# Build the Plutus script
cabal run cardano-plutus-build

# Create script address
cardano-cli address build \
  --payment-script-file token.plutus \
  --testnet-magic 1 \
  --out-file token.addr

# Fund the script address
cardano-cli transaction build \
  --tx-in YOUR_UTXO \
  --tx-out $(cat token.addr)+2000000 \
  --change-address YOUR_ADDRESS \
  --testnet-magic 1 \
  --out-file tx.raw

cardano-cli transaction sign \
  --tx-body-file tx.raw \
  --signing-key-file payment.skey \
  --testnet-magic 1 \
  --out-file tx.signed

cardano-cli transaction submit \
  --testnet-magic 1 \
  --tx-file tx.signed
```

## 📚 Contract Interface

### Token Actions (Redeemers)

- `Transfer { to, amount }` - Transfer tokens to another address
- `Approve { spender, amount }` - Approve spending allowance
- `TransferFrom { from, to, amount }` - Transfer from approved address
- `Mint { to, amount }` - Mint new tokens (owner only)

### Token Datum

```haskell
data TokenDatum = TokenDatum
    { tdBalance     :: Integer        -- Current balance
    , tdAllowances  :: [(PubKeyHash, Integer)]  -- Spending allowances
    }
```

## 🔍 Example Usage

### Transfer Tokens

```haskell
-- Create transfer redeemer
let transferRedeemer = Transfer
      { taTo = recipientPubKeyHash
      , taAmount = 100
      }

-- Build and submit transaction (off-chain code)
```

### Approve Spending

```haskell
-- Create approval redeemer
let approveRedeemer = Approve
      { aaSpender = spenderPubKeyHash
      , aaAmount = 500
      }
```

## 🧪 Testing

```bash
# Run property-based tests
cabal test

# Test with Plutus Application Backend (PAB)
cabal run plutus-pab
```

## 📦 Project Structure

```
haskell/cardano-plutus/
├── cardano-plutus.cabal    # Cabal package file
├── src/
│   └── SimpleToken.hs      # Plutus validator
└── README.md
```

## 🔒 Security Considerations

- **UTXO Model**: Each token balance is a separate UTXO
- **Validator Logic**: All business logic runs on-chain
- **Datum Validation**: Ensures state transitions are valid
- **Signature Checks**: Verifies transaction authorization

## 🌐 Cardano Specifics

### EUTXO Model

Cardano uses Extended UTXO:
- Each UTXO can carry a datum (state)
- Validators check if spending is allowed
- Redeemers provide action context

### Script Context

```haskell
data ScriptContext = ScriptContext
    { scriptContextTxInfo  :: TxInfo
    , scriptContextPurpose :: ScriptPurpose
    }
```

### Plutus Versions

This contract uses **Plutus V2**:
- Improved reference scripts
- Inline datums
- Reference inputs

## 💡 Development Tips

```bash
# Format code
cabal run fourmolu -- -i src/

# Check for warnings
cabal build --ghc-options="-Wall"

# Optimize script size
cabal build --ghc-options="-O2"
```

## 🌐 Resources

- [Plutus Documentation](https://plutus.readthedocs.io/)
- [Cardano Docs](https://docs.cardano.org/)
- [Plutus Pioneer Program](https://github.com/input-output-hk/plutus-pioneer-program)
- [Cardano Stack Exchange](https://cardano.stackexchange.com/)

## 📜 License

MIT
