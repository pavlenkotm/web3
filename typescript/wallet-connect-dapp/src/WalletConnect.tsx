import { useAccount, useConnect, useDisconnect, useBalance, useChainId } from 'wagmi';
import { formatEther } from 'viem';

export function WalletConnect() {
  const { address, isConnected } = useAccount();
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();
  const chainId = useChainId();
  const { data: balance } = useBalance({ address });

  if (isConnected && address) {
    return (
      <div className="wallet-connected">
        <h2>Connected Wallet</h2>
        <p><strong>Address:</strong> {address}</p>
        <p><strong>Chain ID:</strong> {chainId}</p>
        {balance && (
          <p><strong>Balance:</strong> {formatEther(balance.value)} {balance.symbol}</p>
        )}
        <button onClick={() => disconnect()}>Disconnect</button>
      </div>
    );
  }

  return (
    <div className="wallet-connect">
      <h2>Connect Your Wallet</h2>
      <div className="connector-buttons">
        {connectors.map((connector) => (
          <button
            key={connector.id}
            onClick={() => connect({ connector })}
            disabled={!connector.ready}
          >
            Connect with {connector.name}
          </button>
        ))}
      </div>
    </div>
  );
}
