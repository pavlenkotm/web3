# @version ^0.3.10
"""
@title ERC20 Token
@author Web3 Developer
@notice Pythonic smart contract in Vyper
@dev Implementation of the ERC20 token standard
"""

from vyper.interfaces import ERC20

implements: ERC20

# Events
event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    value: uint256

event Approval:
    owner: indexed(address)
    spender: indexed(address)
    value: uint256

# State variables
name: public(String[64])
symbol: public(String[32])
decimals: public(uint8)
totalSupply: public(uint256)

balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])

owner: public(address)

@external
def __init__(_name: String[64], _symbol: String[32], _decimals: uint8, _initialSupply: uint256):
    """
    @notice Contract constructor
    @param _name Token name
    @param _symbol Token symbol
    @param _decimals Number of decimals
    @param _initialSupply Initial token supply
    """
    self.name = _name
    self.symbol = _symbol
    self.decimals = _decimals
    self.totalSupply = _initialSupply * 10 ** convert(_decimals, uint256)
    self.owner = msg.sender

    self.balanceOf[msg.sender] = self.totalSupply

    log Transfer(empty(address), msg.sender, self.totalSupply)

@external
def transfer(_to: address, _value: uint256) -> bool:
    """
    @notice Transfer tokens to another address
    @param _to Recipient address
    @param _value Amount to transfer
    @return Success boolean
    """
    assert _to != empty(address), "Invalid recipient"
    assert self.balanceOf[msg.sender] >= _value, "Insufficient balance"

    self.balanceOf[msg.sender] -= _value
    self.balanceOf[_to] += _value

    log Transfer(msg.sender, _to, _value)
    return True

@external
def transferFrom(_from: address, _to: address, _value: uint256) -> bool:
    """
    @notice Transfer tokens from one address to another
    @param _from Source address
    @param _to Destination address
    @param _value Amount to transfer
    @return Success boolean
    """
    assert _to != empty(address), "Invalid recipient"
    assert self.balanceOf[_from] >= _value, "Insufficient balance"
    assert self.allowance[_from][msg.sender] >= _value, "Insufficient allowance"

    self.balanceOf[_from] -= _value
    self.balanceOf[_to] += _value
    self.allowance[_from][msg.sender] -= _value

    log Transfer(_from, _to, _value)
    return True

@external
def approve(_spender: address, _value: uint256) -> bool:
    """
    @notice Approve spender to transfer tokens
    @param _spender Address to approve
    @param _value Amount to approve
    @return Success boolean
    """
    assert _spender != empty(address), "Invalid spender"

    self.allowance[msg.sender][_spender] = _value

    log Approval(msg.sender, _spender, _value)
    return True

@external
def mint(_to: address, _value: uint256):
    """
    @notice Mint new tokens (owner only)
    @param _to Recipient address
    @param _value Amount to mint
    """
    assert msg.sender == self.owner, "Only owner can mint"
    assert _to != empty(address), "Invalid recipient"

    self.totalSupply += _value
    self.balanceOf[_to] += _value

    log Transfer(empty(address), _to, _value)

@external
def burn(_value: uint256):
    """
    @notice Burn tokens from sender's balance
    @param _value Amount to burn
    """
    assert self.balanceOf[msg.sender] >= _value, "Insufficient balance"

    self.totalSupply -= _value
    self.balanceOf[msg.sender] -= _value

    log Transfer(msg.sender, empty(address), _value)
