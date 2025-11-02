#pragma once

#include "Order.hpp"
#include <map>
#include <vector>
#include <mutex>
#include <functional>

namespace DEX {

struct Trade {
    uint64_t buyOrderId;
    uint64_t sellOrderId;
    double price;
    double quantity;
    std::chrono::system_clock::time_point timestamp;
};

class OrderBook {
public:
    OrderBook(const std::string& tradingPair);

    // Add order to the book
    std::vector<Trade> addOrder(OrderPtr order);

    // Cancel an order
    bool cancelOrder(uint64_t orderId);

    // Get current best bid and ask
    double getBestBid() const;
    double getBestAsk() const;

    // Get market depth
    std::map<double, double> getBidDepth(int levels = 10) const;
    std::map<double, double> getAskDepth(int levels = 10) const;

    // Get all orders for a user
    std::vector<OrderPtr> getUserOrders(const std::string& userId) const;

    const std::string& getTradingPair() const { return tradingPair_; }

private:
    std::string tradingPair_;

    // Price -> Orders at that price
    // For bids: higher price = better, so use std::greater
    std::map<double, std::vector<OrderPtr>, std::greater<double>> bids_;

    // For asks: lower price = better, so use std::less (default)
    std::map<double, std::vector<OrderPtr>> asks_;

    // Order ID -> Order (for quick lookup)
    std::map<uint64_t, OrderPtr> orders_;

    // Thread safety
    mutable std::mutex mutex_;

    // Try to match a new order with existing orders
    std::vector<Trade> matchOrder(OrderPtr order);

    // Execute a trade between two orders
    Trade executeTrade(OrderPtr buyOrder, OrderPtr sellOrder, double price, double quantity);
};

} // namespace DEX
