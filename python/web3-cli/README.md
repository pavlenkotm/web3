# Python Web3 CLI

Professional command-line interface and Python library for Ethereum blockchain interactions using Web3.py.

## Features

- **ETH Balance Queries**: Check account balances
- **Transaction Sending**: Send ETH with automatic gas estimation
- **Block Information**: Query blockchain data
- **Smart Contract Calls**: Read and write contract functions
- **Multi-Network Support**: Ethereum, BSC, Polygon, Arbitrum
- **Account Management**: Load accounts from private keys
- **Rich CLI Output**: Colored tables and formatted data

## Tech Stack

- **Python 3.9+**: Modern Python features
- **Web3.py v6**: Official Ethereum Python library
- **Click**: Command-line interface framework
- **Rich**: Terminal formatting and styling
- **eth-account**: Account and key management
- **pytest**: Testing framework

## Installation

### Prerequisites

- Python 3.9 or higher
- pip package manager

### Setup

```bash
cd python/web3-cli

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install package in development mode
pip install -e .
```

## Configuration

Create `.env` file:

```bash
WEB3_PROVIDER_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY
PRIVATE_KEY=your_private_key_here
```

## Usage

### CLI Commands

#### Get Blockchain Info

```bash
web3cli info
```

#### Check Balance

```bash
web3cli balance 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
```

#### Send ETH

```bash
export PRIVATE_KEY=your_private_key
web3cli send 0xRecipientAddress 0.1
```

#### Get Block Info

```bash
web3cli block 18000000
```

### Python Library Usage

#### Initialize Client

```python
from web3cli.client import Web3Client

# Connect to blockchain
client = Web3Client("https://mainnet.infura.io/v3/YOUR_KEY")

# Check connection
if client.is_connected():
    print(f"Connected to chain ID: {client.get_chain_id()}")
```

#### Query Balance

```python
address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
balance = client.get_balance(address)
print(f"Balance: {balance} ETH")
```

#### Send Transaction

```python
# Load account
private_key = "0x..."
account = client.load_account(private_key)

# Send ETH
tx_hash = client.send_transaction(
    to_address="0xRecipient...",
    value_eth=0.1,
    gas_limit=21000
)

print(f"Transaction: {tx_hash}")

# Wait for confirmation
receipt = client.wait_for_transaction(tx_hash)
if receipt['status'] == 1:
    print("Success!")
```

#### Call Smart Contract

```python
# ERC-20 Token balance
erc20_abi = [...]  # Standard ERC-20 ABI
token_address = "0xTokenContract..."

balance = client.call_contract(
    contract_address=token_address,
    abi=erc20_abi,
    function_name="balanceOf",
    "0xUserAddress..."
)
print(f"Token balance: {balance}")
```

#### Send Contract Transaction

```python
# Approve ERC-20 spending
tx_hash = client.send_contract_transaction(
    contract_address=token_address,
    abi=erc20_abi,
    function_name="approve",
    "0xSpenderAddress...",
    1000000000000000000,  # amount
    gas_limit=100000
)

receipt = client.wait_for_transaction(tx_hash)
```

## Project Structure

```
python/web3-cli/
├── src/
│   └── web3cli/
│       ├── __init__.py       # Package initialization
│       ├── client.py         # Web3Client class
│       └── cli.py            # CLI commands
├── tests/
│   ├── test_client.py        # Client tests
│   └── test_cli.py           # CLI tests
├── requirements.txt          # Dependencies
├── setup.py                  # Package setup
└── README.md                 # Documentation
```

## Testing

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=web3cli tests/

# Run specific test
pytest tests/test_client.py::test_get_balance
```

## Advanced Features

### Multi-Network Support

```python
# Ethereum Mainnet
mainnet = Web3Client("https://eth-mainnet.alchemyapi.io/v2/KEY")

# Polygon
polygon = Web3Client("https://polygon-rpc.com")

# BSC
bsc = Web3Client("https://bsc-dataseed.binance.org/")
```

### Transaction Options

```python
# Custom gas price
tx_hash = client.send_transaction(
    to_address="0x...",
    value_eth=0.1,
    gas_limit=21000
)

# The client automatically:
# - Gets current gas price
# - Retrieves nonce
# - Signs transaction
# - Sends to network
```

### Error Handling

```python
try:
    tx_hash = client.send_transaction("0x...", 0.1)
    receipt = client.wait_for_transaction(tx_hash, timeout=120)

    if receipt['status'] == 0:
        print("Transaction failed")
except ValueError as e:
    print(f"Invalid input: {e}")
except Exception as e:
    print(f"Error: {e}")
```

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `WEB3_PROVIDER_URL` | RPC endpoint URL | `https://mainnet.infura.io/v3/KEY` |
| `PRIVATE_KEY` | Account private key | `0x123...` |

## Common Use Cases

### 1. Monitor Account Balance

```python
addresses = ["0x...", "0x...", "0x..."]
for addr in addresses:
    balance = client.get_balance(addr)
    print(f"{addr}: {balance} ETH")
```

### 2. Bulk Token Transfer

```python
recipients = [("0xAddr1", 1.0), ("0xAddr2", 2.0)]
for addr, amount in recipients:
    tx = client.send_transaction(addr, amount)
    print(f"Sent {amount} ETH to {addr}: {tx}")
```

### 3. Smart Contract Event Monitoring

```python
contract = client.w3.eth.contract(address=addr, abi=abi)
event_filter = contract.events.Transfer.create_filter(fromBlock='latest')

for event in event_filter.get_new_entries():
    print(f"Transfer: {event['args']}")
```

## Dependencies

- `web3>=6.15.0`: Ethereum interactions
- `eth-account>=0.11.0`: Account management
- `click>=8.1.7`: CLI framework
- `rich>=13.7.0`: Terminal formatting
- `python-dotenv>=1.0.0`: Environment management

## Resources

- [Web3.py Documentation](https://web3py.readthedocs.io/)
- [Ethereum JSON-RPC](https://ethereum.org/en/developers/docs/apis/json-rpc/)
- [Click Documentation](https://click.palletsprojects.com/)

## License

MIT
