# Go Ethereum RPC Client

High-performance Ethereum RPC client and CLI tool built with Go and go-ethereum.

## Features

- **Fast RPC Calls**: Native Go performance
- **Balance Queries**: Check ETH balances
- **Block Information**: Query blockchain data
- **Chain Info**: Get chain ID and network details
- **CLI Interface**: User-friendly command-line tool
- **Colored Output**: Rich terminal formatting

## Tech Stack

- **Go 1.21+**: Modern Go features
- **go-ethereum**: Official Ethereum Go library
- **Cobra**: CLI framework
- **fatih/color**: Terminal colors

## Installation

### Prerequisites

- Go 1.21 or higher

### Setup

```bash
cd go/eth-rpc-client

# Download dependencies
go mod download

# Build binary
go build -o eth-rpc

# Install globally (optional)
go install
```

## Usage

### CLI Commands

#### Get Blockchain Info

```bash
./eth-rpc info
```

Output:
```
Chain ID: 1
Latest Block: 19000000
RPC URL: http://localhost:8545
```

#### Check Balance

```bash
./eth-rpc balance 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
```

Output:
```
Balance: 1.234567 ETH
```

#### Get Block Info

```bash
./eth-rpc block 18000000
```

Output:
```
Block #18000000

Hash: 0x...
Parent Hash: 0x...
Timestamp: 1695648023
Transactions: 150
Gas Used: 15000000
Gas Limit: 30000000
```

#### Custom RPC URL

```bash
./eth-rpc --rpc https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY info
```

Or set environment variable:
```bash
export ETH_RPC_URL=https://mainnet.infura.io/v3/YOUR_KEY
./eth-rpc info
```

### Go Library Usage

#### Import Package

```go
import (
    "github.com/web3/eth-rpc-client"
)
```

#### Initialize Client

```go
client, err := NewClient("https://mainnet.infura.io/v3/YOUR_KEY")
if err != nil {
    log.Fatal(err)
}
defer client.Close()
```

#### Get Balance

```go
balance, err := client.GetBalance("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb")
if err != nil {
    log.Fatal(err)
}

ethBalance := new(big.Float).Quo(
    new(big.Float).SetInt(balance),
    big.NewFloat(1e18),
)
fmt.Printf("Balance: %s ETH\n", ethBalance.Text('f', 6))
```

#### Get Latest Block

```go
blockNum, err := client.GetBlockNumber()
if err != nil {
    log.Fatal(err)
}
fmt.Printf("Latest block: %d\n", blockNum)
```

#### Get Block Details

```go
block, err := client.GetBlock(18000000)
if err != nil {
    log.Fatal(err)
}

fmt.Printf("Hash: %s\n", block.Hash().Hex())
fmt.Printf("Transactions: %d\n", len(block.Transactions()))
```

#### Get Chain ID

```go
chainID, err := client.GetChainID()
if err != nil {
    log.Fatal(err)
}
fmt.Printf("Chain ID: %s\n", chainID.String())
```

## Project Structure

```
go/eth-rpc-client/
├── main.go           # Main entry point & CLI
├── go.mod            # Go module definition
├── go.sum            # Dependency checksums
└── README.md         # Documentation
```

## Advanced Usage

### Send Transaction

```go
package main

import (
    "context"
    "crypto/ecdsa"
    "log"
    "math/big"

    "github.com/ethereum/go-ethereum/common"
    "github.com/ethereum/go-ethereum/core/types"
    "github.com/ethereum/go-ethereum/crypto"
    "github.com/ethereum/go-ethereum/ethclient"
)

func sendTransaction() {
    client, _ := ethclient.Dial("http://localhost:8545")

    // Load private key
    privateKey, _ := crypto.HexToECDSA("your_private_key")
    publicKey := privateKey.Public()
    publicKeyECDSA, _ := publicKey.(*ecdsa.PublicKey)
    fromAddress := crypto.PubkeyToAddress(*publicKeyECDSA)

    // Get nonce
    nonce, _ := client.PendingNonceAt(context.Background(), fromAddress)

    // Build transaction
    toAddress := common.HexToAddress("0x...")
    value := big.NewInt(1000000000000000000) // 1 ETH
    gasLimit := uint64(21000)
    gasPrice, _ := client.SuggestGasPrice(context.Background())

    tx := types.NewTransaction(nonce, toAddress, value, gasLimit, gasPrice, nil)

    // Sign transaction
    chainID, _ := client.NetworkID(context.Background())
    signedTx, _ := types.SignTx(tx, types.NewEIP155Signer(chainID), privateKey)

    // Send transaction
    err := client.SendTransaction(context.Background(), signedTx)
    if err != nil {
        log.Fatal(err)
    }

    log.Printf("Transaction sent: %s", signedTx.Hash().Hex())
}
```

### Call Smart Contract

```go
import (
    "github.com/ethereum/go-ethereum/accounts/abi"
    "github.com/ethereum/go-ethereum/common"
)

// Call contract view function
contractAddress := common.HexToAddress("0x...")
data, _ := contractABI.Pack("balanceOf", userAddress)

msg := ethereum.CallMsg{
    To:   &contractAddress,
    Data: data,
}

result, _ := client.CallContract(context.Background(), msg, nil)

// Unpack result
var balance *big.Int
contractABI.UnpackIntoInterface(&balance, "balanceOf", result)
```

### Subscribe to New Blocks

```go
headers := make(chan *types.Header)
sub, err := client.SubscribeNewHead(context.Background(), headers)
if err != nil {
    log.Fatal(err)
}

for {
    select {
    case err := <-sub.Err():
        log.Fatal(err)
    case header := <-headers:
        log.Printf("New block: %d", header.Number.Uint64())
    }
}
```

## Building

### Development Build

```bash
go build -o eth-rpc
```

### Production Build

```bash
go build -ldflags="-s -w" -o eth-rpc
```

### Cross-Compilation

```bash
# Linux
GOOS=linux GOARCH=amd64 go build -o eth-rpc-linux

# macOS
GOOS=darwin GOARCH=amd64 go build -o eth-rpc-mac

# Windows
GOOS=windows GOARCH=amd64 go build -o eth-rpc.exe
```

## Testing

```bash
# Run tests
go test -v ./...

# Run with coverage
go test -cover ./...

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

## Performance

- **RPC Call Latency**: ~50-100ms (network dependent)
- **Memory Usage**: ~10-20 MB
- **Binary Size**: ~15-20 MB
- **Startup Time**: < 100ms

## Dependencies

```go
github.com/ethereum/go-ethereum v1.13.14
github.com/spf13/cobra v1.8.0
github.com/fatih/color v1.16.0
```

## Resources

- [go-ethereum Documentation](https://geth.ethereum.org/docs)
- [Ethereum JSON-RPC](https://ethereum.org/en/developers/docs/apis/json-rpc/)
- [Cobra CLI](https://github.com/spf13/cobra)

## License

MIT
