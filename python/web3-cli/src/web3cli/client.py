"""Web3 client for blockchain interactions."""

from typing import Optional, Dict, Any
from web3 import Web3
from web3.middleware import geth_poa_middleware
from eth_account import Account
from eth_account.signers.local import LocalAccount
import os


class Web3Client:
    """Ethereum Web3 client wrapper."""

    def __init__(self, rpc_url: Optional[str] = None):
        """Initialize Web3 client.

        Args:
            rpc_url: Ethereum RPC endpoint URL
        """
        self.rpc_url = rpc_url or os.getenv("WEB3_PROVIDER_URL", "http://localhost:8545")
        self.w3 = Web3(Web3.HTTPProvider(self.rpc_url))

        # Add PoA middleware for networks like BSC, Polygon
        self.w3.middleware_onion.inject(geth_poa_middleware, layer=0)

        self.account: Optional[LocalAccount] = None

    def is_connected(self) -> bool:
        """Check if connected to blockchain."""
        return self.w3.is_connected()

    def get_chain_id(self) -> int:
        """Get current chain ID."""
        return self.w3.eth.chain_id

    def get_block_number(self) -> int:
        """Get latest block number."""
        return self.w3.eth.block_number

    def get_balance(self, address: str) -> float:
        """Get ETH balance for address.

        Args:
            address: Ethereum address

        Returns:
            Balance in ETH
        """
        checksum_address = Web3.to_checksum_address(address)
        balance_wei = self.w3.eth.get_balance(checksum_address)
        return float(self.w3.from_wei(balance_wei, 'ether'))

    def load_account(self, private_key: str) -> LocalAccount:
        """Load account from private key.

        Args:
            private_key: Private key (with or without 0x prefix)

        Returns:
            LocalAccount instance
        """
        if not private_key.startswith('0x'):
            private_key = '0x' + private_key

        self.account = Account.from_key(private_key)
        return self.account

    def send_transaction(
        self,
        to_address: str,
        value_eth: float,
        gas_limit: int = 21000
    ) -> str:
        """Send ETH transaction.

        Args:
            to_address: Recipient address
            value_eth: Amount in ETH
            gas_limit: Gas limit

        Returns:
            Transaction hash
        """
        if not self.account:
            raise ValueError("No account loaded. Call load_account() first.")

        to_address = Web3.to_checksum_address(to_address)
        value_wei = self.w3.to_wei(value_eth, 'ether')

        # Build transaction
        tx = {
            'from': self.account.address,
            'to': to_address,
            'value': value_wei,
            'gas': gas_limit,
            'gasPrice': self.w3.eth.gas_price,
            'nonce': self.w3.eth.get_transaction_count(self.account.address),
            'chainId': self.get_chain_id(),
        }

        # Sign and send
        signed_tx = self.account.sign_transaction(tx)
        tx_hash = self.w3.eth.send_raw_transaction(signed_tx.rawTransaction)

        return tx_hash.hex()

    def wait_for_transaction(self, tx_hash: str, timeout: int = 120) -> Dict[str, Any]:
        """Wait for transaction confirmation.

        Args:
            tx_hash: Transaction hash
            timeout: Timeout in seconds

        Returns:
            Transaction receipt
        """
        receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash, timeout=timeout)
        return dict(receipt)

    def call_contract(
        self,
        contract_address: str,
        abi: list,
        function_name: str,
        *args
    ) -> Any:
        """Call contract view function.

        Args:
            contract_address: Contract address
            abi: Contract ABI
            function_name: Function name
            *args: Function arguments

        Returns:
            Function return value
        """
        contract_address = Web3.to_checksum_address(contract_address)
        contract = self.w3.eth.contract(address=contract_address, abi=abi)
        return contract.functions[function_name](*args).call()

    def send_contract_transaction(
        self,
        contract_address: str,
        abi: list,
        function_name: str,
        *args,
        value_eth: float = 0,
        gas_limit: int = 200000
    ) -> str:
        """Send contract transaction.

        Args:
            contract_address: Contract address
            abi: Contract ABI
            function_name: Function name
            *args: Function arguments
            value_eth: ETH value to send
            gas_limit: Gas limit

        Returns:
            Transaction hash
        """
        if not self.account:
            raise ValueError("No account loaded. Call load_account() first.")

        contract_address = Web3.to_checksum_address(contract_address)
        contract = self.w3.eth.contract(address=contract_address, abi=abi)

        # Build transaction
        tx = contract.functions[function_name](*args).build_transaction({
            'from': self.account.address,
            'value': self.w3.to_wei(value_eth, 'ether'),
            'gas': gas_limit,
            'gasPrice': self.w3.eth.gas_price,
            'nonce': self.w3.eth.get_transaction_count(self.account.address),
            'chainId': self.get_chain_id(),
        })

        # Sign and send
        signed_tx = self.account.sign_transaction(tx)
        tx_hash = self.w3.eth.send_raw_transaction(signed_tx.rawTransaction)

        return tx_hash.hex()
