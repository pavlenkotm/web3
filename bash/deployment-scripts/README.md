# Bash Deployment Scripts

Professional shell scripts for Web3 development automation and smart contract deployment.

## Features

- **Contract Deployment**: Automated deployment to multiple networks
- **Node Management**: Start local Ethereum nodes
- **Network Verification**: Contract verification on Etherscan
- **Multi-Network**: Support for localhost, testnets, mainnet
- **Error Handling**: Robust error checking
- **Colored Output**: User-friendly terminal output

## Scripts

### deploy-contract.sh

Deploys smart contracts to Ethereum networks.

```bash
./deploy-contract.sh --network sepolia --verify
```

**Options:**
- `-n, --network NETWORK`: Target network (localhost, sepolia, mainnet)
- `-v, --verify`: Verify contract on Etherscan
- `-h, --help`: Show help message

**Usage:**

```bash
# Deploy to localhost
./deploy-contract.sh --network localhost

# Deploy to Sepolia testnet
PRIVATE_KEY=0x... ./deploy-contract.sh --network sepolia

# Deploy to mainnet with verification
PRIVATE_KEY=0x... \
ETHERSCAN_API_KEY=ABC123 \
./deploy-contract.sh --network mainnet --verify
```

### start-node.sh

Starts local Ethereum development node.

```bash
./start-node.sh
```

**Environment Variables:**
- `NODE_TYPE`: Node type (hardhat, ganache, anvil)
- `PORT`: Port number (default: 8545)
- `FORK_URL`: Fork from mainnet URL
- `CHAINID`: Chain ID (default: 31337)

**Usage:**

```bash
# Start Hardhat node
./start-node.sh

# Start with mainnet fork
FORK_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY \
./start-node.sh

# Start Ganache
NODE_TYPE=ganache ./start-node.sh

# Start Anvil (Foundry)
NODE_TYPE=anvil PORT=8545 ./start-node.sh
```

## Setup

### Make Scripts Executable

```bash
chmod +x deploy-contract.sh
chmod +x start-node.sh
```

### Environment Variables

Create `.env` file:

```bash
# Network RPCs
SEPOLIA_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY
MAINNET_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY

# Private keys (NEVER commit to git!)
PRIVATE_KEY=0x...

# API keys
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_KEY
```

Load environment:

```bash
source .env
```

Or use with script:

```bash
export $(cat .env | xargs) && ./deploy-contract.sh
```

## Complete Deployment Workflow

### 1. Start Local Node

Terminal 1:
```bash
./start-node.sh
```

### 2. Deploy Contract

Terminal 2:
```bash
./deploy-contract.sh --network localhost
```

### 3. Deploy to Testnet

```bash
# Set environment
export PRIVATE_KEY=0x...
export SEPOLIA_URL=https://eth-sepolia.g.alchemy.com/v2/KEY

# Deploy
./deploy-contract.sh --network sepolia --verify
```

### 4. Deploy to Mainnet (Production)

```bash
# Double-check everything!
export PRIVATE_KEY=0x...
export MAINNET_URL=https://eth-mainnet.g.alchemy.com/v2/KEY
export ETHERSCAN_API_KEY=ABC123

# Deploy (with confirmation prompt)
./deploy-contract.sh --network mainnet --verify
```

## Advanced Usage

### Deploy with Hardhat

```bash
#!/bin/bash
# deploy-with-hardhat.sh

npx hardhat run scripts/deploy.js --network sepolia

# Verify
npx hardhat verify --network sepolia DEPLOYED_CONTRACT_ADDRESS
```

### Deploy with Foundry

```bash
#!/bin/bash
# deploy-with-foundry.sh

forge script script/Deploy.s.sol:DeployScript \
  --rpc-url $SEPOLIA_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

### Multi-Contract Deployment

```bash
#!/bin/bash
# deploy-all.sh

contracts=("Token" "DEX" "Governance")

for contract in "${contracts[@]}"; do
    echo "Deploying $contract..."
    npx hardhat run "scripts/deploy${contract}.js" --network sepolia
done
```

### Deployment Verification Loop

```bash
#!/bin/bash

DEPLOYMENT_FILE="deployments/sepolia.json"
CONTRACT_ADDRESS=$(jq -r '.address' $DEPLOYMENT_FILE)

# Wait for deployment
while true; do
    CODE=$(cast code $CONTRACT_ADDRESS --rpc-url $SEPOLIA_URL)
    if [ "$CODE" != "0x" ]; then
        echo "Contract deployed!"
        break
    fi
    sleep 5
done

# Verify on Etherscan
npx hardhat verify --network sepolia $CONTRACT_ADDRESS
```

## Error Handling

Scripts include comprehensive error checking:

```bash
# Check if command exists
if ! command -v node &> /dev/null; then
    echo "Error: Node.js not installed"
    exit 1
fi

# Check file exists
if [ ! -f "hardhat.config.js" ]; then
    echo "Error: hardhat.config.js not found"
    exit 1
fi

# Check environment variable
if [ -z "$PRIVATE_KEY" ]; then
    echo "Error: PRIVATE_KEY not set"
    exit 1
fi
```

## Integration with CI/CD

### GitHub Actions

```yaml
name: Deploy Contract

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm install

      - name: Deploy to Sepolia
        env:
          PRIVATE_KEY: ${{ secrets.PRIVATE_KEY }}
          SEPOLIA_URL: ${{ secrets.SEPOLIA_URL }}
        run: |
          chmod +x bash/deployment-scripts/deploy-contract.sh
          bash/deployment-scripts/deploy-contract.sh --network sepolia
```

## Best Practices

1. **Never commit private keys**: Use `.gitignore` for `.env`
2. **Test on testnet first**: Always deploy to Sepolia/Goerli before mainnet
3. **Verify contracts**: Use `--verify` flag for transparency
4. **Use .env files**: Centralize configuration
5. **Add confirmation prompts**: Especially for mainnet
6. **Log everything**: Save deployment addresses and timestamps
7. **Error handling**: Check all commands with `set -e`
8. **Use colors**: Make output readable

## Troubleshooting

### Node not starting

```bash
# Kill existing process on port 8545
lsof -ti:8545 | xargs kill -9

# Try again
./start-node.sh
```

### Deployment fails

```bash
# Check network connection
curl -X POST $SEPOLIA_URL \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'

# Check account balance
cast balance $YOUR_ADDRESS --rpc-url $SEPOLIA_URL
```

### Verification fails

```bash
# Retry with delay
sleep 30
npx hardhat verify --network sepolia $CONTRACT_ADDRESS
```

## Resources

- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)
- [Hardhat Documentation](https://hardhat.org/)
- [Foundry Book](https://book.getfoundry.sh/)

## License

MIT
