# Usage Examples

## Quick Start Examples

### Deploy and Interact with Smart Contracts

```javascript
// Deploy ERC-20 Token
const token = await Token.deploy("MyToken", "MTK", 1000000);

// Mint tokens
await token.mint(userAddress, 1000);

// Transfer
await token.transfer(recipient, 100);
```

### Python CLI Usage

```bash
# Check balance
web3cli balance 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb

# Send transaction
web3cli send --to 0x... --amount 0.1
```

### TypeScript DApp

```typescript
import { useAccount, useBalance } from 'wagmi'

const { address } = useAccount()
const { data } = useBalance({ address })
```

See individual project READMEs for more detailed examples.
