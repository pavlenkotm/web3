#pragma once

#include "OrderBook.hpp"
#include <map>
#include <string>
#include <memory>
#include <mutex>
#include <atomic>

namespace DEX {

class MatchingEngine {
public:
    MatchingEngine();

    // Add a new trading pair
    bool addTradingPair(const std::string& pair);

    // Submit an order
    std::vector<Trade> submitOrder(const std::string& userId,
                                   const std::string& tradingPair,
                                   OrderSide side,
                                   OrderType type,
                                   double price,
                                   double quantity);

    // Cancel an order
    bool cancelOrder(uint64_t orderId, const std::string& tradingPair);

    // Get orderbook for a trading pair
    std::shared_ptr<OrderBook> getOrderBook(const std::string& tradingPair);

    // Get market data
    struct MarketData {
        double bestBid;
        double bestAsk;
        double spread;
        std::map<double, double> bidDepth;
        std::map<double, double> askDepth;
    };

    MarketData getMarketData(const std::string& tradingPair) const;

    // Get user's orders
    std::vector<OrderPtr> getUserOrders(const std::string& userId,
                                       const std::string& tradingPair) const;

    // Statistics
    uint64_t getTotalOrders() const { return orderIdCounter_; }
    size_t getTradingPairCount() const { return orderBooks_.size(); }

private:
    std::map<std::string, std::shared_ptr<OrderBook>> orderBooks_;
    std::atomic<uint64_t> orderIdCounter_;
    mutable std::mutex mutex_;

    uint64_t generateOrderId() {
        return ++orderIdCounter_;
    }
};

} // namespace DEX
