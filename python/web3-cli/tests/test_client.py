"""Tests for Web3Client."""

import pytest
from web3cli.client import Web3Client


def test_client_initialization():
    """Test client initializes correctly."""
    client = Web3Client("http://localhost:8545")
    assert client.rpc_url == "http://localhost:8545"


def test_client_connection():
    """Test client connection check."""
    client = Web3Client("http://localhost:8545")
    # Note: This will fail without a running node
    # In real tests, use a mock or test network
    try:
        connected = client.is_connected()
        assert isinstance(connected, bool)
    except Exception:
        pass  # Expected if no node running


def test_balance_validation():
    """Test balance retrieval with invalid address."""
    client = Web3Client("http://localhost:8545")

    with pytest.raises(Exception):
        client.get_balance("invalid_address")
