const DEXClient = require('./DEXClient');
const { ethers } = require('ethers');

/**
 * Example usage of DEXClient
 */
async function main() {
    console.log('=== DEX Web3 Client Example ===\n');

    // Configuration (replace with actual values)
    const PROVIDER_URL = 'http://localhost:8545';
    const CONTRACT_ADDRESS = '0x5FbDB2315678afecb367f032d93F642f64180aa3'; // Example address
    const PRIVATE_KEY = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'; // Example key

    // Minimal ABI for testing (in production, import full ABI from artifacts)
    const CONTRACT_ABI = [
        'function deposit(address token, uint256 amount)',
        'function withdraw(address token, uint256 amount)',
        'function getBalance(address user, address token) view returns (uint256)',
        'function getOrder(uint256 orderId) view returns (tuple(uint256 id, address user, address baseToken, address quoteToken, uint8 side, uint8 orderType, uint8 status, uint256 price, uint256 quantity, uint256 filledQuantity, uint256 timestamp))',
        'function cancelOrder(uint256 orderId)',
        'event Deposit(address indexed user, address indexed token, uint256 amount)',
        'event OrderPlaced(uint256 indexed orderId, address indexed user, uint8 side, uint256 price, uint256 quantity)',
        'event TradeExecuted(uint256 indexed buyOrderId, uint256 indexed sellOrderId, uint256 price, uint256 quantity)'
    ];

    // Create client
    const client = new DEXClient(CONTRACT_ADDRESS, CONTRACT_ABI, PROVIDER_URL);

    // Connect wallet
    client.connectWallet(PRIVATE_KEY);
    console.log('✓ Wallet connected');

    // Example token address
    const TOKEN_ADDRESS = '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0';

    // Listen to events
    console.log('\n=== Setting up event listeners ===');

    client.onDeposit((event) => {
        console.log('📥 Deposit event:', event);
    });

    client.onOrderPlaced((event) => {
        console.log('📝 Order placed:', event);
    });

    client.onTradeExecuted((event) => {
        console.log('✅ Trade executed:', event);
    });

    console.log('✓ Event listeners active\n');

    // Example: Get balance
    try {
        const userAddress = await client.wallet.getAddress();
        console.log('=== Checking balance ===');
        const balance = await client.getBalance(userAddress, TOKEN_ADDRESS);
        console.log(`Balance: ${ethers.formatEther(balance)} tokens\n`);
    } catch (error) {
        console.log('Note: Balance check failed (contract may not be deployed yet)\n');
    }

    // Example: Deposit
    /*
    console.log('=== Depositing tokens ===');
    const depositAmount = ethers.parseEther('100');
    await client.deposit(TOKEN_ADDRESS, depositAmount);
    */

    // Example: Get order
    /*
    console.log('\n=== Getting order info ===');
    const order = await client.getOrder(1);
    console.log('Order details:', order);
    */

    console.log('=== Example complete ===');
    console.log('\nNote: Uncomment code sections to test deposit and order operations');
    console.log('Make sure to deploy the contracts first using: npm run deploy\n');

    // Clean up
    client.removeAllListeners();
}

// Run example
if (require.main === module) {
    main()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
}

module.exports = { main };
