# Quick Start Guide

This guide will help you get the DEX Trading Engine up and running in minutes.

## Prerequisites

Make sure you have the following installed:

```bash
# Check versions
g++ --version      # Should be 9+ or Clang 10+
cmake --version    # Should be 3.15+
node --version     # Should be 16+
npm --version
```

## Step 1: Clone and Install

```bash
# Clone the repository
git clone <your-repo-url>
cd web3

# Install Node.js dependencies
npm install
```

## Step 2: Build C++ Components

```bash
# Create build directory
mkdir build && cd build

# Configure with CMake
cmake -DCMAKE_BUILD_TYPE=Release ..

# Build
make -j$(nproc)

# Run demo
./dex_demo
```

Expected output:
```
=== DEX Trading Engine Demo ===

Added trading pair: ETH/USDT

--- Submitting Buy Orders ---
User1: BUY 1.5 ETH @ 2000 USDT
...
```

## Step 3: Smart Contracts (When Network Available)

```bash
cd /home/user/web3

# Compile contracts
npm run compile

# Start local blockchain (Terminal 1)
npm run node

# Deploy contracts (Terminal 2)
npm run deploy

# Run tests
npm test
```

## Step 4: Try the Examples

### C++ Example

```cpp
#include "MatchingEngine.hpp"

using namespace DEX;

int main() {
    // Create engine
    MatchingEngine engine;

    // Add trading pair
    engine.addTradingPair("BTC/USDT");

    // Submit orders
    auto trades = engine.submitOrder(
        "alice",
        "BTC/USDT",
        OrderSide::BUY,
        OrderType::LIMIT,
        50000.0,  // price
        0.5       // quantity
    );

    // Get market data
    auto data = engine.getMarketData("BTC/USDT");
    std::cout << "Best Bid: " << data.bestBid << std::endl;
    std::cout << "Best Ask: " << data.bestAsk << std::endl;

    return 0;
}
```

### JavaScript Example

```javascript
const DEXClient = require('./web3/src/DEXClient');
const { ethers } = require('ethers');

async function main() {
    // Setup
    const provider = 'http://localhost:8545';
    const contractAddress = '0x...'; // From deployment
    const privateKey = '0x...';

    // Create client
    const client = new DEXClient(
        contractAddress,
        CONTRACT_ABI,
        provider
    );

    client.connectWallet(privateKey);

    // Deposit tokens
    const tokenAddress = '0x...';
    const amount = ethers.parseEther('100');
    await client.deposit(tokenAddress, amount);

    // Listen to events
    client.onTradeExecuted((event) => {
        console.log('Trade:', event);
    });
}

main();
```

## Common Issues

### Issue: CMake not found
```bash
# Ubuntu/Debian
sudo apt-get install cmake

# macOS
brew install cmake
```

### Issue: Compiler too old
```bash
# Ubuntu/Debian
sudo apt-get install build-essential g++-9

# Set as default
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 90
```

### Issue: Node modules missing
```bash
# Clean install
rm -rf node_modules package-lock.json
npm install
```

### Issue: Can't compile Solidity contracts
This is due to network restrictions in some environments. The contracts are already written and will compile when network access is available. You can still:
- Use the C++ engine independently
- Review the contract code
- Prepare for deployment

## Next Steps

1. **Explore the Code**: Check out the architecture in `docs/ARCHITECTURE.md`
2. **Customize**: Add new trading pairs, order types, or features
3. **Deploy**: Deploy to testnets or mainnet (after thorough testing!)
4. **Integrate**: Connect your frontend or trading bot

## Testing

### C++ Tests
```bash
cd build
# Run demo with different scenarios
./dex_demo
```

### Smart Contract Tests
```bash
# When network is available
npm test
```

## Performance Tips

### C++ Optimization
```bash
# Build with maximum optimization
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-O3 -march=native" ..
make
```

### Profiling
```bash
# Install perf (Linux)
sudo apt-get install linux-tools-common

# Profile the demo
perf record ./dex_demo
perf report
```

## Project Structure Recap

```
web3/
├── cpp/               # C++ matching engine
│   ├── include/       # Headers
│   └── src/           # Implementation
├── contracts/         # Solidity contracts
│   ├── src/           # Contract code
│   └── test/          # Contract tests
├── web3/              # Web3 integration
│   └── src/           # JS client
├── docs/              # Documentation
└── scripts/           # Deployment scripts
```

## Help

- **Documentation**: See `README.md` and `docs/ARCHITECTURE.md`
- **Issues**: Check existing issues or create a new one
- **Examples**: Look in `cpp/src/main.cpp` and `web3/src/example.js`

## What's Next?

Now that you have the basics running:

1. **Read ARCHITECTURE.md** to understand the system design
2. **Modify the demo** to test different trading scenarios
3. **Write your own orders** using the C++ or JS APIs
4. **Explore gas optimization** for the smart contracts
5. **Add features** like stop-loss orders or fee mechanisms

Happy trading! 🚀
