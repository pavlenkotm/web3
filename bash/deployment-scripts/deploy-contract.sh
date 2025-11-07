#!/bin/bash

###############################################################################
# Smart Contract Deployment Script
# Deploys Ethereum smart contracts to various networks
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NETWORK=${NETWORK:-"localhost"}
CONTRACT_DIR=${CONTRACT_DIR:-"./contracts"}
BUILD_DIR=${BUILD_DIR:-"./build"}

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    log_info "Checking dependencies..."

    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed"
        exit 1
    fi

    if ! command -v npm &> /dev/null; then
        log_error "npm is not installed"
        exit 1
    fi

    if [ ! -f "package.json" ]; then
        log_error "package.json not found"
        exit 1
    fi

    log_info "All dependencies satisfied"
}

install_packages() {
    log_info "Installing npm packages..."
    npm install
}

compile_contracts() {
    log_info "Compiling contracts..."

    if command -v hardhat &> /dev/null; then
        npx hardhat compile
    elif command -v forge &> /dev/null; then
        forge build
    else
        log_error "No compiler found (hardhat or forge)"
        exit 1
    fi

    log_info "Compilation successful"
}

deploy_to_network() {
    local network=$1
    log_info "Deploying to network: $network"

    case $network in
        localhost|hardhat)
            log_info "Deploying to local network..."
            npx hardhat run scripts/deploy.js --network localhost
            ;;
        sepolia)
            log_info "Deploying to Sepolia testnet..."
            npx hardhat run scripts/deploy.js --network sepolia
            ;;
        mainnet)
            log_warn "Deploying to MAINNET! Are you sure? (y/n)"
            read -r confirm
            if [ "$confirm" = "y" ]; then
                npx hardhat run scripts/deploy.js --network mainnet
            else
                log_info "Deployment cancelled"
                exit 0
            fi
            ;;
        *)
            log_error "Unknown network: $network"
            exit 1
            ;;
    esac
}

verify_contract() {
    local address=$1
    local network=$2

    log_info "Verifying contract at $address on $network..."

    npx hardhat verify --network "$network" "$address"

    log_info "Verification complete"
}

save_deployment_info() {
    local network=$1
    local address=$2

    log_info "Saving deployment information..."

    mkdir -p deployments

    cat > "deployments/${network}.json" <<EOF
{
  "network": "$network",
  "address": "$address",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "deployer": "$DEPLOYER_ADDRESS"
}
EOF

    log_info "Deployment info saved to deployments/${network}.json"
}

# Main execution
main() {
    log_info "=== Smart Contract Deployment ==="

    check_dependencies
    install_packages
    compile_contracts
    deploy_to_network "$NETWORK"

    log_info "=== Deployment Complete ==="
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--network)
            NETWORK="$2"
            shift 2
            ;;
        -v|--verify)
            VERIFY=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -n, --network NETWORK    Target network (localhost, sepolia, mainnet)"
            echo "  -v, --verify             Verify contract on Etherscan"
            echo "  -h, --help               Show this help message"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

main
