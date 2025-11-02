#include "../include/MatchingEngine.hpp"
#include <stdexcept>

namespace DEX {

MatchingEngine::MatchingEngine() : orderIdCounter_(0) {}

bool MatchingEngine::addTradingPair(const std::string& pair) {
    std::lock_guard<std::mutex> lock(mutex_);

    if (orderBooks_.find(pair) != orderBooks_.end()) {
        return false; // Already exists
    }

    orderBooks_[pair] = std::make_shared<OrderBook>(pair);
    return true;
}

std::vector<Trade> MatchingEngine::submitOrder(const std::string& userId,
                                               const std::string& tradingPair,
                                               OrderSide side,
                                               OrderType type,
                                               double price,
                                               double quantity) {
    if (quantity <= 0) {
        throw std::invalid_argument("Quantity must be positive");
    }

    if (type == OrderType::LIMIT && price <= 0) {
        throw std::invalid_argument("Price must be positive for limit orders");
    }

    auto orderBook = getOrderBook(tradingPair);
    if (!orderBook) {
        throw std::runtime_error("Trading pair not found: " + tradingPair);
    }

    uint64_t orderId = generateOrderId();
    auto order = std::make_shared<Order>(
        orderId, userId, tradingPair, side, type, price, quantity
    );

    return orderBook->addOrder(order);
}

bool MatchingEngine::cancelOrder(uint64_t orderId, const std::string& tradingPair) {
    auto orderBook = getOrderBook(tradingPair);
    if (!orderBook) {
        return false;
    }

    return orderBook->cancelOrder(orderId);
}

std::shared_ptr<OrderBook> MatchingEngine::getOrderBook(const std::string& tradingPair) {
    std::lock_guard<std::mutex> lock(mutex_);

    auto it = orderBooks_.find(tradingPair);
    if (it == orderBooks_.end()) {
        return nullptr;
    }

    return it->second;
}

MatchingEngine::MarketData MatchingEngine::getMarketData(const std::string& tradingPair) const {
    std::lock_guard<std::mutex> lock(mutex_);

    auto it = orderBooks_.find(tradingPair);
    if (it == orderBooks_.end()) {
        throw std::runtime_error("Trading pair not found: " + tradingPair);
    }

    auto& orderBook = it->second;

    MarketData data;
    data.bestBid = orderBook->getBestBid();
    data.bestAsk = orderBook->getBestAsk();
    data.spread = (data.bestAsk > 0 && data.bestBid > 0)
        ? (data.bestAsk - data.bestBid)
        : 0.0;
    data.bidDepth = orderBook->getBidDepth(10);
    data.askDepth = orderBook->getAskDepth(10);

    return data;
}

std::vector<OrderPtr> MatchingEngine::getUserOrders(const std::string& userId,
                                                    const std::string& tradingPair) const {
    std::lock_guard<std::mutex> lock(mutex_);

    auto it = orderBooks_.find(tradingPair);
    if (it == orderBooks_.end()) {
        return {};
    }

    return it->second->getUserOrders(userId);
}

} // namespace DEX
