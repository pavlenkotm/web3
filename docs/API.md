# API Reference

Complete API documentation for the DEX Trading Engine.

## C++ API

### MatchingEngine

Main class for managing the trading engine.

#### Constructor

```cpp
MatchingEngine();
```

Creates a new matching engine instance.

#### Methods

##### addTradingPair

```cpp
bool addTradingPair(const std::string& pair);
```

Adds a new trading pair to the engine.

**Parameters:**
- `pair`: Trading pair identifier (e.g., "ETH/USDT")

**Returns:** `true` if successful, `false` if pair already exists

**Example:**
```cpp
engine.addTradingPair("BTC/USDT");
engine.addTradingPair("ETH/USDC");
```

##### submitOrder

```cpp
std::vector<Trade> submitOrder(
    const std::string& userId,
    const std::string& tradingPair,
    OrderSide side,
    OrderType type,
    double price,
    double quantity
);
```

Submits a new order to the matching engine.

**Parameters:**
- `userId`: User identifier
- `tradingPair`: Trading pair (must exist)
- `side`: `OrderSide::BUY` or `OrderSide::SELL`
- `type`: `OrderType::MARKET` or `OrderType::LIMIT`
- `price`: Price per unit (0 for market orders)
- `quantity`: Order quantity

**Returns:** Vector of executed trades

**Throws:** `std::invalid_argument` if parameters are invalid

**Example:**
```cpp
auto trades = engine.submitOrder(
    "user123",
    "ETH/USDT",
    OrderSide::BUY,
    OrderType::LIMIT,
    2000.0,
    1.5
);

for (const auto& trade : trades) {
    std::cout << "Traded " << trade.quantity
              << " @ " << trade.price << std::endl;
}
```

##### cancelOrder

```cpp
bool cancelOrder(uint64_t orderId, const std::string& tradingPair);
```

Cancels an existing order.

**Parameters:**
- `orderId`: ID of the order to cancel
- `tradingPair`: Trading pair of the order

**Returns:** `true` if cancelled, `false` if not found

##### getMarketData

```cpp
MarketData getMarketData(const std::string& tradingPair) const;
```

Gets current market data for a trading pair.

**Returns:** MarketData struct with:
- `bestBid`: Best bid price (0 if no bids)
- `bestAsk`: Best ask price (0 if no asks)
- `spread`: Bid-ask spread
- `bidDepth`: Map of price levels to quantities (bids)
- `askDepth`: Map of price levels to quantities (asks)

**Example:**
```cpp
auto data = engine.getMarketData("ETH/USDT");
std::cout << "Spread: " << data.spread << std::endl;

for (const auto& [price, qty] : data.bidDepth) {
    std::cout << "Bid: " << price << " x " << qty << std::endl;
}
```

##### getUserOrders

```cpp
std::vector<OrderPtr> getUserOrders(
    const std::string& userId,
    const std::string& tradingPair
) const;
```

Gets all active orders for a user.

**Returns:** Vector of order pointers

### OrderBook

Manages orders for a single trading pair.

#### Methods

##### addOrder

```cpp
std::vector<Trade> addOrder(OrderPtr order);
```

Adds an order and attempts to match it.

##### cancelOrder

```cpp
bool cancelOrder(uint64_t orderId);
```

Cancels an order by ID.

##### getBestBid/getBestAsk

```cpp
double getBestBid() const;
double getBestAsk() const;
```

Gets the best bid/ask price.

##### getBidDepth/getAskDepth

```cpp
std::map<double, double> getBidDepth(int levels = 10) const;
std::map<double, double> getAskDepth(int levels = 10) const;
```

Gets orderbook depth up to specified levels.

### Data Structures

#### Order

```cpp
struct Order {
    uint64_t id;
    std::string userId;
    std::string tradingPair;
    OrderSide side;
    OrderType type;
    OrderStatus status;
    double price;
    double quantity;
    double filledQuantity;
    std::chrono::system_clock::time_point timestamp;
};
```

#### Trade

```cpp
struct Trade {
    uint64_t buyOrderId;
    uint64_t sellOrderId;
    double price;
    double quantity;
    std::chrono::system_clock::time_point timestamp;
};
```

#### Enums

```cpp
enum class OrderSide { BUY, SELL };
enum class OrderType { MARKET, LIMIT };
enum class OrderStatus { PENDING, PARTIAL, FILLED, CANCELLED };
```

## Smart Contract API

### DEXContract

Main contract for the decentralized exchange.

#### Events

##### Deposit

```solidity
event Deposit(
    address indexed user,
    address indexed token,
    uint256 amount
);
```

##### Withdraw

```solidity
event Withdraw(
    address indexed user,
    address indexed token,
    uint256 amount
);
```

##### OrderPlaced

```solidity
event OrderPlaced(
    uint256 indexed orderId,
    address indexed user,
    OrderSide side,
    uint256 price,
    uint256 quantity
);
```

##### TradeExecuted

```solidity
event TradeExecuted(
    uint256 indexed buyOrderId,
    uint256 indexed sellOrderId,
    uint256 price,
    uint256 quantity
);
```

#### Functions

##### deposit

```solidity
function deposit(address token, uint256 amount) external;
```

Deposits tokens into the exchange.

**Requirements:**
- Token must be approved first
- Amount must be > 0

##### withdraw

```solidity
function withdraw(address token, uint256 amount) external;
```

Withdraws tokens from the exchange.

**Requirements:**
- User must have sufficient balance

##### placeOrder

```solidity
function placeOrder(
    uint256 orderId,
    address user,
    address baseToken,
    address quoteToken,
    OrderSide side,
    OrderType orderType,
    uint256 price,
    uint256 quantity
) external onlyOwner;
```

Places an order (owner only - called by matching engine).

##### executeTrade

```solidity
function executeTrade(
    uint256 buyOrderId,
    uint256 sellOrderId,
    uint256 price,
    uint256 quantity
) external onlyOwner;
```

Executes a trade between two orders (owner only).

##### cancelOrder

```solidity
function cancelOrder(uint256 orderId) external;
```

Cancels an order. Can be called by order owner or contract owner.

##### getBalance

```solidity
function getBalance(
    address user,
    address token
) external view returns (uint256);
```

Gets user's balance for a token.

##### getOrder

```solidity
function getOrder(uint256 orderId)
    external view returns (Order memory);
```

Gets order details by ID.

## Web3 JavaScript API

### DEXClient

Client for interacting with smart contracts.

#### Constructor

```javascript
new DEXClient(contractAddress, contractABI, providerUrl)
```

**Parameters:**
- `contractAddress`: Deployed contract address
- `contractABI`: Contract ABI
- `providerUrl`: RPC provider URL

#### Methods

##### connectWallet

```javascript
connectWallet(privateKey)
```

Connects a wallet using private key.

##### deposit

```javascript
async deposit(tokenAddress, amount)
```

Deposits tokens to the DEX.

**Returns:** Transaction receipt

##### withdraw

```javascript
async withdraw(tokenAddress, amount)
```

Withdraws tokens from the DEX.

**Returns:** Transaction receipt

##### getBalance

```javascript
async getBalance(userAddress, tokenAddress)
```

Gets user's balance.

**Returns:** BigInt balance

##### getOrder

```javascript
async getOrder(orderId)
```

Gets order details.

**Returns:** Order object

##### cancelOrder

```javascript
async cancelOrder(orderId)
```

Cancels an order.

**Returns:** Transaction receipt

#### Event Listeners

##### onDeposit

```javascript
onDeposit((event) => {
    console.log('Deposit:', event);
});
```

##### onOrderPlaced

```javascript
onOrderPlaced((event) => {
    console.log('Order:', event);
});
```

##### onTradeExecuted

```javascript
onTradeExecuted((event) => {
    console.log('Trade:', event);
});
```

## Usage Examples

### Full Trading Flow

```cpp
// C++ Side - Matching Engine
MatchingEngine engine;
engine.addTradingPair("ETH/USDT");

// User 1 submits buy order
auto trades1 = engine.submitOrder(
    "user1", "ETH/USDT",
    OrderSide::BUY, OrderType::LIMIT,
    2000.0, 1.0
);

// User 2 submits sell order
auto trades2 = engine.submitOrder(
    "user2", "ETH/USDT",
    OrderSide::SELL, OrderType::LIMIT,
    2000.0, 1.0
);

// Trade is matched automatically
if (!trades2.empty()) {
    // Settle on-chain via Web3
}
```

```javascript
// JavaScript Side - On-chain Settlement
const client = new DEXClient(CONTRACT_ADDR, ABI, PROVIDER);

// Listen for trades
client.onTradeExecuted(async (event) => {
    console.log(`Trade executed: ${event.quantity} @ ${event.price}`);
});

// User deposits
await client.deposit(TOKEN_ADDR, ethers.parseEther('100'));

// Check balance
const balance = await client.getBalance(userAddr, TOKEN_ADDR);
```

## Error Handling

### C++ Exceptions

```cpp
try {
    engine.submitOrder(...);
} catch (const std::invalid_argument& e) {
    std::cerr << "Invalid order: " << e.what() << std::endl;
} catch (const std::runtime_error& e) {
    std::cerr << "Runtime error: " << e.what() << std::endl;
}
```

### Solidity Reverts

```javascript
try {
    await dex.deposit(token, amount);
} catch (error) {
    if (error.message.includes('Insufficient balance')) {
        console.error('Not enough tokens');
    }
}
```

## Rate Limits & Constraints

- **C++ Engine**: ~50,000 orders/second (single-threaded)
- **Blockchain**: Limited by network TPS
- **Min Order Size**: Configurable per trading pair
- **Max Order Size**: Limited by uint256 (2^256-1)
- **Price Precision**: Double precision (C++), 18 decimals (Solidity)

## Security Considerations

1. **Always validate inputs** before submitting to blockchain
2. **Check balances** before placing orders
3. **Use events** to track order status
4. **Implement timeouts** for long-running operations
5. **Monitor gas costs** on mainnet

## Further Reading

- [Architecture Documentation](ARCHITECTURE.md)
- [Quick Start Guide](QUICKSTART.md)
- [Main README](../README.md)
