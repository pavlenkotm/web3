#!/bin/bash

###############################################################################
# Ethereum Node Startup Script
# Starts local Ethereum node with optional configurations
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
NODE_TYPE=${NODE_TYPE:-"hardhat"}
PORT=${PORT:-8545}
FORK_URL=${FORK_URL:-""}
CHAINID=${CHAINID:-31337}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

start_hardhat_node() {
    log_info "Starting Hardhat node on port $PORT..."

    if [ -n "$FORK_URL" ]; then
        log_info "Forking from: $FORK_URL"
        npx hardhat node --fork "$FORK_URL" --port "$PORT"
    else
        npx hardhat node --port "$PORT"
    fi
}

start_ganache() {
    log_info "Starting Ganache on port $PORT..."

    npx ganache-cli \
        --port "$PORT" \
        --chainId "$CHAINID" \
        --deterministic \
        --accounts 10 \
        --defaultBalanceEther 10000
}

start_anvil() {
    log_info "Starting Anvil (Foundry) on port $PORT..."

    if [ -n "$FORK_URL" ]; then
        anvil --port "$PORT" --fork-url "$FORK_URL"
    else
        anvil --port "$PORT"
    fi
}

# Main
case $NODE_TYPE in
    hardhat)
        start_hardhat_node
        ;;
    ganache)
        start_ganache
        ;;
    anvil)
        start_anvil
        ;;
    *)
        log_warn "Unknown node type: $NODE_TYPE"
        log_info "Using Hardhat as default"
        start_hardhat_node
        ;;
esac
