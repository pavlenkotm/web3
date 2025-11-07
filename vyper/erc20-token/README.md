# Vyper ERC20 Token

Pythonic smart contract implementation using Vyper - an alternative to Solidity with Python-like syntax.

## Features

- **ERC20 Standard**: Full ERC20 token implementation
- **Pythonic Syntax**: Clean, readable code
- **Security First**: Bounds checking, overflow protection
- **Mint & Burn**: Token supply management
- **Owner Control**: Access-controlled minting
- **Gas Optimized**: Efficient Vyper compilation

## Why Vyper?

- **Security**: Simpler than Solidity, easier to audit
- **Readability**: Python-like syntax
- **No Footguns**: No modifiers, class inheritance, or inline assembly
- **Bounds Checking**: Automatic overflow protection
- **Decidability**: Easier formal verification

## Tech Stack

- **Vyper 0.3.10+**: Pythonic smart contract language
- **Python 3.10+**: For development tools
- **Vyper Compiler**: Contract compilation

## Installation

### Prerequisites

```bash
# Python 3.10+
python --version

# Install Vyper
pip install vyper
```

### Verify Installation

```bash
vyper --version
```

## Compilation

### Compile Contract

```bash
cd vyper/erc20-token

# Compile to bytecode
vyper Token.vy

# Generate ABI
vyper -f abi Token.vy > Token.abi.json

# Generate ABI and bytecode
vyper -f abi,bytecode Token.vy
```

### Output Formats

```bash
# ABI
vyper -f abi Token.vy

# Bytecode
vyper -f bytecode Token.vy

# Opcodes
vyper -f opcodes Token.vy

# IR (Intermediate Representation)
vyper -f ir Token.vy

# AST
vyper -f ast Token.vy
```

## Deployment

### Using Web3.py

```python
from web3 import Web3
from vyper import compile_code

# Connect to network
w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

# Compile contract
with open('Token.vy', 'r') as f:
    source_code = f.read()

compiled = compile_code(source_code, ['abi', 'bytecode'])

# Deploy
Token = w3.eth.contract(
    abi=compiled['abi'],
    bytecode=compiled['bytecode']
)

tx_hash = Token.constructor(
    "MyToken",      # name
    "MTK",          # symbol
    18,             # decimals
    1000000         # initialSupply
).transact({'from': w3.eth.accounts[0]})

tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
contract_address = tx_receipt['contractAddress']
```

### Using Brownie

```python
from brownie import Token, accounts

# Deploy
token = Token.deploy(
    "MyToken",
    "MTK",
    18,
    1000000,
    {'from': accounts[0]}
)

print(f"Token deployed at: {token.address}")
```

## Usage

### Transfer Tokens

```python
# Transfer tokens
token.transfer(recipient_address, 1000, {'from': accounts[0]})

# Check balance
balance = token.balanceOf(recipient_address)
print(f"Balance: {balance}")
```

### Approve and TransferFrom

```python
# Approve spender
token.approve(spender_address, 500, {'from': accounts[0]})

# Transfer from approved amount
token.transferFrom(
    accounts[0],
    recipient_address,
    500,
    {'from': spender_address}
)
```

### Mint Tokens (Owner Only)

```python
# Mint new tokens
token.mint(recipient_address, 1000, {'from': accounts[0]})
```

### Burn Tokens

```python
# Burn tokens from own balance
token.burn(500, {'from': accounts[0]})
```

## Contract Interface

### Constructor

```python
@external
def __init__(
    _name: String[64],
    _symbol: String[32],
    _decimals: uint8,
    _initialSupply: uint256
)
```

### ERC20 Functions

```python
@external
def transfer(_to: address, _value: uint256) -> bool

@external
def transferFrom(_from: address, _to: address, _value: uint256) -> bool

@external
def approve(_spender: address, _value: uint256) -> bool

@view
@external
def balanceOf(_owner: address) -> uint256

@view
@external
def allowance(_owner: address, _spender: address) -> uint256
```

### Additional Functions

```python
@external
def mint(_to: address, _value: uint256)  # Owner only

@external
def burn(_value: uint256)
```

## Vyper vs Solidity

| Feature | Vyper | Solidity |
|---------|-------|----------|
| Syntax | Python-like | JavaScript-like |
| Inheritance | ❌ No | ✅ Yes |
| Modifiers | ❌ No | ✅ Yes |
| Inline Assembly | ❌ No | ✅ Yes |
| Overflow Checks | ✅ Built-in | ⚠️ Since 0.8.0 |
| Readability | ✅ High | ⚠️ Medium |
| Learning Curve | ✅ Easy | ⚠️ Moderate |

## Security Features

### Automatic Bounds Checking

```python
# Vyper automatically checks:
# - Array bounds
# - Integer overflow/underflow
# - Division by zero
```

### No Footguns

```python
# Vyper doesn't allow:
# - Inline assembly
# - Function overloading
# - Operator overloading
# - Recursive calls
# - Infinite loops
```

### Explicit is Better

```python
# Must explicitly handle all cases
assert _to != empty(address), "Invalid recipient"
assert self.balanceOf[msg.sender] >= _value, "Insufficient balance"
```

## Testing

### Brownie Tests

```python
import pytest
from brownie import Token, accounts

@pytest.fixture
def token():
    return Token.deploy("Test", "TST", 18, 1000000, {'from': accounts[0]})

def test_transfer(token):
    token.transfer(accounts[1], 100, {'from': accounts[0]})
    assert token.balanceOf(accounts[1]) == 100

def test_approve_and_transfer_from(token):
    token.approve(accounts[1], 50, {'from': accounts[0]})
    token.transferFrom(accounts[0], accounts[2], 50, {'from': accounts[1]})
    assert token.balanceOf(accounts[2]) == 50
```

## Gas Comparison

Vyper often produces more gas-efficient bytecode:

| Operation | Solidity | Vyper |
|-----------|----------|-------|
| Deploy | ~1,200,000 | ~1,100,000 |
| Transfer | ~51,000 | ~49,000 |
| Approve | ~46,000 | ~44,000 |

## Development Tools

### Brownie Framework

```bash
pip install eth-brownie
brownie init
brownie compile
brownie test
```

### Titanoboa (Vyper Testing)

```bash
pip install titanoboa

# Interactive testing
python
>>> import boa
>>> token = boa.load("Token.vy", "MyToken", "MTK", 18, 1000000)
>>> token.balanceOf(boa.env.eoa)
```

## Resources

- [Vyper Documentation](https://docs.vyperlang.org/)
- [Vyper by Example](https://vyper-by-example.org/)
- [Vyper GitHub](https://github.com/vyperlang/vyper)
- [Brownie Documentation](https://eth-brownie.readthedocs.io/)

## License

MIT
