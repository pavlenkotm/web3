#pragma once

#include <string>
#include <chrono>
#include <memory>

namespace DEX {

enum class OrderSide {
    BUY,
    SELL
};

enum class OrderType {
    MARKET,
    LIMIT
};

enum class OrderStatus {
    PENDING,
    PARTIAL,
    FILLED,
    CANCELLED
};

struct Order {
    uint64_t id;
    std::string userId;
    std::string tradingPair;  // e.g., "ETH/USDT"
    OrderSide side;
    OrderType type;
    OrderStatus status;
    double price;             // Price per unit (0 for market orders)
    double quantity;          // Original quantity
    double filledQuantity;    // Quantity filled so far
    std::chrono::system_clock::time_point timestamp;

    Order(uint64_t id, const std::string& userId, const std::string& pair,
          OrderSide side, OrderType type, double price, double quantity)
        : id(id), userId(userId), tradingPair(pair), side(side), type(type),
          status(OrderStatus::PENDING), price(price), quantity(quantity),
          filledQuantity(0.0), timestamp(std::chrono::system_clock::now()) {}

    double getRemainingQuantity() const {
        return quantity - filledQuantity;
    }

    bool isFilled() const {
        return filledQuantity >= quantity;
    }
};

using OrderPtr = std::shared_ptr<Order>;

} // namespace DEX
