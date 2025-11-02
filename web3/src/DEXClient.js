const { ethers } = require('ethers');

/**
 * DEXClient - Client for interacting with DEX smart contract
 */
class DEXClient {
    constructor(contractAddress, contractABI, providerUrl) {
        this.provider = new ethers.JsonRpcProvider(providerUrl);
        this.contract = new ethers.Contract(contractAddress, contractABI, this.provider);
        this.contractAddress = contractAddress;
    }

    /**
     * Connect wallet to the client
     */
    connectWallet(privateKey) {
        this.wallet = new ethers.Wallet(privateKey, this.provider);
        this.contract = this.contract.connect(this.wallet);
    }

    /**
     * Deposit tokens to the DEX
     */
    async deposit(tokenAddress, amount) {
        try {
            // First approve the DEX contract to spend tokens
            const tokenContract = new ethers.Contract(
                tokenAddress,
                ['function approve(address spender, uint256 amount) returns (bool)'],
                this.wallet
            );

            const approveTx = await tokenContract.approve(this.contractAddress, amount);
            await approveTx.wait();
            console.log('Token approval confirmed');

            // Then deposit
            const tx = await this.contract.deposit(tokenAddress, amount);
            const receipt = await tx.wait();
            console.log('Deposit confirmed:', receipt.hash);
            return receipt;
        } catch (error) {
            console.error('Deposit failed:', error);
            throw error;
        }
    }

    /**
     * Withdraw tokens from the DEX
     */
    async withdraw(tokenAddress, amount) {
        try {
            const tx = await this.contract.withdraw(tokenAddress, amount);
            const receipt = await tx.wait();
            console.log('Withdrawal confirmed:', receipt.hash);
            return receipt;
        } catch (error) {
            console.error('Withdrawal failed:', error);
            throw error;
        }
    }

    /**
     * Get user balance for a token
     */
    async getBalance(userAddress, tokenAddress) {
        try {
            const balance = await this.contract.getBalance(userAddress, tokenAddress);
            return balance;
        } catch (error) {
            console.error('Failed to get balance:', error);
            throw error;
        }
    }

    /**
     * Get order details
     */
    async getOrder(orderId) {
        try {
            const order = await this.contract.getOrder(orderId);
            return {
                id: order.id.toString(),
                user: order.user,
                baseToken: order.baseToken,
                quoteToken: order.quoteToken,
                side: order.side === 0 ? 'BUY' : 'SELL',
                orderType: order.orderType === 0 ? 'MARKET' : 'LIMIT',
                status: ['PENDING', 'PARTIAL', 'FILLED', 'CANCELLED'][order.status],
                price: ethers.formatEther(order.price),
                quantity: ethers.formatEther(order.quantity),
                filledQuantity: ethers.formatEther(order.filledQuantity),
                timestamp: new Date(Number(order.timestamp) * 1000).toISOString()
            };
        } catch (error) {
            console.error('Failed to get order:', error);
            throw error;
        }
    }

    /**
     * Cancel an order
     */
    async cancelOrder(orderId) {
        try {
            const tx = await this.contract.cancelOrder(orderId);
            const receipt = await tx.wait();
            console.log('Order cancelled:', receipt.hash);
            return receipt;
        } catch (error) {
            console.error('Failed to cancel order:', error);
            throw error;
        }
    }

    /**
     * Listen to Deposit events
     */
    onDeposit(callback) {
        this.contract.on('Deposit', (user, token, amount, event) => {
            callback({
                user,
                token,
                amount: ethers.formatEther(amount),
                blockNumber: event.log.blockNumber
            });
        });
    }

    /**
     * Listen to OrderPlaced events
     */
    onOrderPlaced(callback) {
        this.contract.on('OrderPlaced', (orderId, user, side, price, quantity, event) => {
            callback({
                orderId: orderId.toString(),
                user,
                side: side === 0 ? 'BUY' : 'SELL',
                price: ethers.formatEther(price),
                quantity: ethers.formatEther(quantity),
                blockNumber: event.log.blockNumber
            });
        });
    }

    /**
     * Listen to TradeExecuted events
     */
    onTradeExecuted(callback) {
        this.contract.on('TradeExecuted', (buyOrderId, sellOrderId, price, quantity, event) => {
            callback({
                buyOrderId: buyOrderId.toString(),
                sellOrderId: sellOrderId.toString(),
                price: ethers.formatEther(price),
                quantity: ethers.formatEther(quantity),
                blockNumber: event.log.blockNumber
            });
        });
    }

    /**
     * Stop listening to all events
     */
    removeAllListeners() {
        this.contract.removeAllListeners();
    }
}

module.exports = DEXClient;
