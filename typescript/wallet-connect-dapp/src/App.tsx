import { WagmiProvider } from 'wagmi';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { config } from './config';
import { WalletConnect } from './WalletConnect';
import './App.css';

const queryClient = new QueryClient();

function App() {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <div className="app">
          <header>
            <h1>Web3 Multi-Chain DApp</h1>
            <p>Powered by Wagmi + Viem</p>
          </header>
          <main>
            <WalletConnect />
          </main>
        </div>
      </QueryClientProvider>
    </WagmiProvider>
  );
}

export default App;
