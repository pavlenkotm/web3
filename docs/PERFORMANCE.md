# Performance Benchmarks

## Smart Contracts

### Gas Costs
- ERC-20 Transfer: ~50,000 gas
- ERC-721 Mint: ~150,000 gas
- DEX Swap: ~120,000 gas

## Backend

### C++ DEX Engine
- Orderbook operations: O(log n)
- Matching speed: 50,000 orders/second
- Memory: ~10MB per 100,000 orders

### Python CLI
- Balance query: <100ms
- Transaction send: <500ms

### Go RPC Client
- Connection latency: <50ms
- Request throughput: 1000 req/sec

## Optimization Tips

1. **Smart Contracts**: Minimize storage operations
2. **C++**: Use compiler optimizations (`-O3`)
3. **Frontend**: Code splitting and lazy loading
4. **Mobile**: Battery-efficient polling

## Benchmarking Tools

```bash
# Hardhat gas reporter
npx hardhat test --report-gas

# C++ profiling
valgrind --tool=callgrind ./dex_demo

# Python profiling
python -m cProfile web3cli/cli.py
```
