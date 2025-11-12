# 🌌 Cosmos SDK Token Module (Go)

A custom token module implementation using the Cosmos SDK in Go, demonstrating how to build blockchain modules for the Cosmos ecosystem with IBC compatibility.

## 📋 Features

- ✅ Custom token module with Cosmos SDK
- ✅ Transfer functionality
- ✅ Mint and burn capabilities
- ✅ Event emission
- ✅ State management with KV store
- ✅ Query and transaction handlers
- ✅ IBC-compatible architecture

## 🛠️ Prerequisites

- [Go](https://golang.org/) 1.21+
- [Cosmos SDK](https://github.com/cosmos/cosmos-sdk) v0.47+
- [Ignite CLI](https://ignite.com/) (optional, for scaffolding)

```bash
# Install Go
# Visit https://golang.org/doc/install

# Install Ignite CLI (optional)
curl https://get.ignite.com/cli! | bash

# Verify installation
go version
ignite version
```

## 🚀 Quick Start

### Initialize Module

```bash
# Clone or create project
mkdir -p cosmos-chain
cd cosmos-chain

# Initialize a new blockchain (using Ignite)
ignite scaffold chain example-chain

# Or manually integrate this module into your chain
```

### Build Module

```bash
# Download dependencies
go mod download

# Build the module
go build ./...

# Run tests
go test ./...
```

### Integration into Chain

```go
// In app/app.go

import (
    tokenkeeper "github.com/example/token/x/token/keeper"
    tokentypes "github.com/example/token/x/token/types"
)

// Add to module manager
app.mm = module.NewManager(
    // ... other modules
    token.NewAppModule(app.TokenKeeper),
)

// Initialize keeper
app.TokenKeeper = tokenkeeper.NewKeeper(
    appCodec,
    keys[tokentypes.StoreKey],
    keys[tokentypes.MemStoreKey],
)
```

## 📚 Module Interface

### Messages (Transactions)

```go
// Transfer tokens
type MsgTransfer struct {
    FromAddress string
    ToAddress   string
    Amount      sdk.Int
    Denom       string
}

// Mint tokens
type MsgMint struct {
    ToAddress string
    Amount    sdk.Int
    Denom     string
}

// Burn tokens
type MsgBurn struct {
    FromAddress string
    Amount      sdk.Int
    Denom       string
}
```

### Queries

```bash
# Query balance
exampled query token balance [address] [denom]

# Query all balances
exampled query token balances [address]
```

## 🔍 Example Usage

### Transfer Tokens via CLI

```bash
# Transfer 100 tokens
exampled tx token transfer \
  cosmos1... \
  100 \
  utoken \
  --from alice \
  --chain-id testchain \
  --fees 5000stake

# Query balance
exampled query token balance cosmos1... utoken
```

### Using in Go Code

```go
package main

import (
    sdk "github.com/cosmos/cosmos-sdk/types"
    "github.com/example/token/x/token/keeper"
    "github.com/example/token/x/token/types"
)

func TransferTokens(k keeper.Keeper, ctx sdk.Context) error {
    from, _ := sdk.AccAddressFromBech32("cosmos1...")
    to, _ := sdk.AccAddressFromBech32("cosmos1...")

    amount := sdk.NewInt(100)
    denom := "utoken"

    return k.Transfer(ctx, from, to, denom, amount)
}

func CheckBalance(k keeper.Keeper, ctx sdk.Context) sdk.Int {
    addr, _ := sdk.AccAddressFromBech32("cosmos1...")
    return k.GetBalance(ctx, addr, "utoken")
}
```

## 🧪 Testing

```bash
# Run all tests
go test ./...

# Run with coverage
go test -cover ./...

# Run specific test
go test ./x/token/keeper -v -run TestTransfer

# Run with race detection
go test -race ./...
```

### Example Test

```go
func TestTransfer(t *testing.T) {
    k, ctx := setupKeeper(t)

    from := sdk.AccAddress("from_address")
    to := sdk.AccAddress("to_address")

    // Mint initial balance
    k.Mint(ctx, from, "utoken", sdk.NewInt(1000))

    // Transfer
    err := k.Transfer(ctx, from, to, "utoken", sdk.NewInt(100))
    require.NoError(t, err)

    // Verify balances
    fromBalance := k.GetBalance(ctx, from, "utoken")
    toBalance := k.GetBalance(ctx, to, "utoken")

    require.Equal(t, sdk.NewInt(900), fromBalance)
    require.Equal(t, sdk.NewInt(100), toBalance)
}
```

## 📦 Project Structure

```
go/cosmos-sdk-module/
├── go.mod
├── x/token/
│   ├── keeper/
│   │   └── keeper.go       # Business logic
│   └── types/
│       ├── types.go        # Data structures
│       ├── msg.go          # Message types
│       └── codec.go        # Encoding
└── README.md
```

## 🔐 Security Features

- **Deterministic execution**: Consistent across all validators
- **State machine replication**: Byzantine fault tolerant
- **Event-driven**: Transparent state changes
- **Access control**: Signer verification
- **Overflow protection**: Safe integer operations

## 🌐 Cosmos SDK Features

### State Management

```go
// Using KV store
store := ctx.KVStore(k.storeKey)
key := types.BalanceKey(addr, denom)
store.Set(key, value)
```

### Events

```go
ctx.EventManager().EmitEvent(
    sdk.NewEvent(
        types.EventTypeTransfer,
        sdk.NewAttribute("from", from.String()),
        sdk.NewAttribute("to", to.String()),
        sdk.NewAttribute("amount", amount.String()),
    ),
)
```

### Queries

```go
func (k Keeper) Balance(
    c context.Context,
    req *types.QueryBalanceRequest,
) (*types.QueryBalanceResponse, error) {
    ctx := sdk.UnwrapSDKContext(c)
    addr, _ := sdk.AccAddressFromBech32(req.Address)
    balance := k.GetBalance(ctx, addr, req.Denom)
    return &types.QueryBalanceResponse{Balance: balance}, nil
}
```

## 🚀 Deployment

### Local Testnet

```bash
# Initialize node
exampled init mynode --chain-id testchain

# Add genesis account
exampled keys add alice
exampled add-genesis-account alice 100000000stake

# Create genesis transaction
exampled gentx alice 1000000stake --chain-id testchain

# Collect genesis txs
exampled collect-gentxs

# Start node
exampled start
```

### Production Deployment

```bash
# Build binary
go build -o exampled ./cmd/exampled

# Deploy with Ansible/Terraform
# Configure systemd service
# Set up monitoring and alerting
```

## 🌐 Resources

- [Cosmos SDK Documentation](https://docs.cosmos.network/)
- [Cosmos SDK Tutorials](https://tutorials.cosmos.network/)
- [IBC Protocol](https://ibc.cosmos.network/)
- [Ignite CLI](https://docs.ignite.com/)

## 📜 License

MIT
