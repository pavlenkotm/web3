# TypeScript Wallet Connect DApp

Modern Web3 decentralized application built with TypeScript, React, Wagmi v2, and Viem.

## Features

- **Multi-Chain Support**: Ethereum, Sepolia, Polygon, Arbitrum
- **Wagmi v2**: Latest hooks-based Web3 React library
- **Viem**: Type-safe Ethereum interactions
- **WalletConnect v2**: Connect with any mobile wallet
- **MetaMask Integration**: Direct browser wallet connection
- **TypeScript**: Full type safety and autocomplete

## Tech Stack

- **TypeScript**: Type-safe JavaScript
- **React 18**: Modern UI framework
- **Wagmi v2**: Web3 React hooks
- **Viem**: Ethereum library
- **TanStack Query**: Data fetching and caching
- **Vite**: Fast build tool

## Setup

### Prerequisites

- Node.js 18+ and npm
- A WalletConnect Project ID from [cloud.walletconnect.com](https://cloud.walletconnect.com)

### Installation

```bash
cd typescript/wallet-connect-dapp
npm install
```

### Configuration

Create `.env` file:

```bash
VITE_WALLETCONNECT_PROJECT_ID=your_project_id_here
```

### Run Development Server

```bash
npm run dev
```

Open http://localhost:5173

### Build for Production

```bash
npm run build
npm run preview
```

## Usage

### Connect Wallet

```typescript
import { useConnect } from 'wagmi';

const { connect, connectors } = useConnect();

// Connect with MetaMask
connect({ connector: connectors[0] });
```

### Read Balance

```typescript
import { useBalance } from 'wagmi';

const { data: balance } = useBalance({ address: '0x...' });
console.log(formatEther(balance.value));
```

### Send Transaction

```typescript
import { useSendTransaction } from 'wagmi';
import { parseEther } from 'viem';

const { sendTransaction } = useSendTransaction();

sendTransaction({
  to: '0x...',
  value: parseEther('0.01'),
});
```

### Read Smart Contract

```typescript
import { useReadContract } from 'wagmi';

const { data } = useReadContract({
  address: '0x...',
  abi: contractABI,
  functionName: 'balanceOf',
  args: [address],
});
```

## Project Structure

```
typescript/wallet-connect-dapp/
├── src/
│   ├── config.ts          # Wagmi configuration
│   ├── WalletConnect.tsx  # Wallet connection component
│   ├── App.tsx            # Main app component
│   └── App.css            # Styles
├── package.json           # Dependencies
├── tsconfig.json          # TypeScript config
└── vite.config.ts         # Vite configuration
```

## Key Concepts

### Wagmi Hooks

- `useAccount()`: Get connected wallet info
- `useConnect()`: Connect to wallets
- `useDisconnect()`: Disconnect wallet
- `useBalance()`: Read native token balance
- `useReadContract()`: Call contract read functions
- `useWriteContract()`: Execute contract transactions
- `useWaitForTransaction()`: Wait for tx confirmation

### Type Safety

Viem provides full TypeScript support:

```typescript
import { parseEther, formatEther, Address } from 'viem';

const amount: bigint = parseEther('1.0');
const formatted: string = formatEther(amount);
const addr: Address = '0x...';
```

## Testing

```bash
npm test
```

## Linting

```bash
npm run lint
```

## Resources

- [Wagmi Docs](https://wagmi.sh)
- [Viem Docs](https://viem.sh)
- [WalletConnect](https://walletconnect.com)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

## License

MIT
