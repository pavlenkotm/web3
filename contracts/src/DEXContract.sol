// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DEXContract
 * @dev Decentralized Exchange smart contract for token trading
 * Works in conjunction with off-chain C++ matching engine
 */
contract DEXContract is ReentrancyGuard, Ownable {

    enum OrderSide { BUY, SELL }
    enum OrderType { MARKET, LIMIT }
    enum OrderStatus { PENDING, PARTIAL, FILLED, CANCELLED }

    struct Order {
        uint256 id;
        address user;
        address baseToken;
        address quoteToken;
        OrderSide side;
        OrderType orderType;
        OrderStatus status;
        uint256 price;
        uint256 quantity;
        uint256 filledQuantity;
        uint256 timestamp;
    }

    struct Trade {
        uint256 buyOrderId;
        uint256 sellOrderId;
        uint256 price;
        uint256 quantity;
        uint256 timestamp;
    }

    // Mapping from order ID to Order
    mapping(uint256 => Order) public orders;

    // User balances for each token
    mapping(address => mapping(address => uint256)) public balances;

    // Events
    event Deposit(address indexed user, address indexed token, uint256 amount);
    event Withdraw(address indexed user, address indexed token, uint256 amount);
    event OrderPlaced(uint256 indexed orderId, address indexed user, OrderSide side, uint256 price, uint256 quantity);
    event OrderCancelled(uint256 indexed orderId);
    event TradeExecuted(uint256 indexed buyOrderId, uint256 indexed sellOrderId, uint256 price, uint256 quantity);

    constructor() Ownable(msg.sender) {}

    /**
     * @dev Deposit tokens into the exchange
     */
    function deposit(address token, uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Transfer failed");

        balances[msg.sender][token] += amount;
        emit Deposit(msg.sender, token, amount);
    }

    /**
     * @dev Withdraw tokens from the exchange
     */
    function withdraw(address token, uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender][token] >= amount, "Insufficient balance");

        balances[msg.sender][token] -= amount;
        require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");

        emit Withdraw(msg.sender, token, amount);
    }

    /**
     * @dev Place an order (called by authorized matching engine)
     */
    function placeOrder(
        uint256 orderId,
        address user,
        address baseToken,
        address quoteToken,
        OrderSide side,
        OrderType orderType,
        uint256 price,
        uint256 quantity
    ) external onlyOwner {
        require(orders[orderId].id == 0, "Order ID already exists");

        // Check user has sufficient balance
        if (side == OrderSide.BUY) {
            uint256 requiredQuote = (price * quantity) / 1e18;
            require(balances[user][quoteToken] >= requiredQuote, "Insufficient quote token balance");
            balances[user][quoteToken] -= requiredQuote; // Lock funds
        } else {
            require(balances[user][baseToken] >= quantity, "Insufficient base token balance");
            balances[user][baseToken] -= quantity; // Lock funds
        }

        orders[orderId] = Order({
            id: orderId,
            user: user,
            baseToken: baseToken,
            quoteToken: quoteToken,
            side: side,
            orderType: orderType,
            status: OrderStatus.PENDING,
            price: price,
            quantity: quantity,
            filledQuantity: 0,
            timestamp: block.timestamp
        });

        emit OrderPlaced(orderId, user, side, price, quantity);
    }

    /**
     * @dev Execute a trade (called by authorized matching engine)
     */
    function executeTrade(
        uint256 buyOrderId,
        uint256 sellOrderId,
        uint256 price,
        uint256 quantity
    ) external onlyOwner nonReentrant {
        Order storage buyOrder = orders[buyOrderId];
        Order storage sellOrder = orders[sellOrderId];

        require(buyOrder.id != 0, "Buy order not found");
        require(sellOrder.id != 0, "Sell order not found");
        require(buyOrder.side == OrderSide.BUY, "Invalid buy order");
        require(sellOrder.side == OrderSide.SELL, "Invalid sell order");

        uint256 quoteAmount = (price * quantity) / 1e18;

        // Transfer base token from seller to buyer
        balances[buyOrder.user][buyOrder.baseToken] += quantity;

        // Transfer quote token from buyer to seller
        balances[sellOrder.user][sellOrder.quoteToken] += quoteAmount;

        // Update order status
        buyOrder.filledQuantity += quantity;
        sellOrder.filledQuantity += quantity;

        if (buyOrder.filledQuantity >= buyOrder.quantity) {
            buyOrder.status = OrderStatus.FILLED;
        } else {
            buyOrder.status = OrderStatus.PARTIAL;
        }

        if (sellOrder.filledQuantity >= sellOrder.quantity) {
            sellOrder.status = OrderStatus.FILLED;
        } else {
            sellOrder.status = OrderStatus.PARTIAL;
        }

        emit TradeExecuted(buyOrderId, sellOrderId, price, quantity);
    }

    /**
     * @dev Cancel an order
     */
    function cancelOrder(uint256 orderId) external {
        Order storage order = orders[orderId];
        require(order.id != 0, "Order not found");
        require(order.user == msg.sender || msg.sender == owner(), "Not authorized");
        require(order.status == OrderStatus.PENDING || order.status == OrderStatus.PARTIAL, "Cannot cancel");

        uint256 remainingQuantity = order.quantity - order.filledQuantity;

        // Return locked funds
        if (order.side == OrderSide.BUY) {
            uint256 remainingQuote = (order.price * remainingQuantity) / 1e18;
            balances[order.user][order.quoteToken] += remainingQuote;
        } else {
            balances[order.user][order.baseToken] += remainingQuantity;
        }

        order.status = OrderStatus.CANCELLED;
        emit OrderCancelled(orderId);
    }

    /**
     * @dev Get user balance for a token
     */
    function getBalance(address user, address token) external view returns (uint256) {
        return balances[user][token];
    }

    /**
     * @dev Get order details
     */
    function getOrder(uint256 orderId) external view returns (Order memory) {
        return orders[orderId];
    }
}
