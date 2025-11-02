#include "../include/OrderBook.hpp"
#include <algorithm>
#include <stdexcept>

namespace DEX {

OrderBook::OrderBook(const std::string& tradingPair)
    : tradingPair_(tradingPair) {}

std::vector<Trade> OrderBook::addOrder(OrderPtr order) {
    std::lock_guard<std::mutex> lock(mutex_);

    if (order->tradingPair != tradingPair_) {
        throw std::invalid_argument("Order trading pair doesn't match orderbook");
    }

    orders_[order->id] = order;

    // Try to match the order
    auto trades = matchOrder(order);

    // If order is not fully filled, add to the book
    if (!order->isFilled()) {
        if (order->side == OrderSide::BUY) {
            bids_[order->price].push_back(order);
        } else {
            asks_[order->price].push_back(order);
        }
    }

    return trades;
}

std::vector<Trade> OrderBook::matchOrder(OrderPtr newOrder) {
    std::vector<Trade> trades;

    if (newOrder->type == OrderType::MARKET) {
        // Market orders match at any price
        auto& oppositeBook = (newOrder->side == OrderSide::BUY) ? asks_ : bids_;

        while (!newOrder->isFilled() && !oppositeBook.empty()) {
            auto& [price, orders] = *oppositeBook.begin();

            while (!newOrder->isFilled() && !orders.empty()) {
                auto oppositeOrder = orders.front();

                double matchPrice = oppositeOrder->price;
                double matchQuantity = std::min(
                    newOrder->getRemainingQuantity(),
                    oppositeOrder->getRemainingQuantity()
                );

                auto trade = executeTrade(
                    (newOrder->side == OrderSide::BUY) ? newOrder : oppositeOrder,
                    (newOrder->side == OrderSide::SELL) ? newOrder : oppositeOrder,
                    matchPrice,
                    matchQuantity
                );

                trades.push_back(trade);

                // Remove filled order
                if (oppositeOrder->isFilled()) {
                    orders.erase(orders.begin());
                }
            }

            // Remove empty price level
            if (orders.empty()) {
                oppositeBook.erase(oppositeBook.begin());
            }
        }
    } else {
        // Limit orders match only at acceptable prices
        auto& oppositeBook = (newOrder->side == OrderSide::BUY) ? asks_ : bids_;

        while (!newOrder->isFilled() && !oppositeBook.empty()) {
            auto& [price, orders] = *oppositeBook.begin();

            // Check if price is acceptable
            bool priceAcceptable = (newOrder->side == OrderSide::BUY)
                ? (price <= newOrder->price)
                : (price >= newOrder->price);

            if (!priceAcceptable) {
                break;
            }

            while (!newOrder->isFilled() && !orders.empty()) {
                auto oppositeOrder = orders.front();

                double matchPrice = oppositeOrder->price;
                double matchQuantity = std::min(
                    newOrder->getRemainingQuantity(),
                    oppositeOrder->getRemainingQuantity()
                );

                auto trade = executeTrade(
                    (newOrder->side == OrderSide::BUY) ? newOrder : oppositeOrder,
                    (newOrder->side == OrderSide::SELL) ? newOrder : oppositeOrder,
                    matchPrice,
                    matchQuantity
                );

                trades.push_back(trade);

                if (oppositeOrder->isFilled()) {
                    orders.erase(orders.begin());
                }
            }

            if (orders.empty()) {
                oppositeBook.erase(oppositeBook.begin());
            }
        }
    }

    return trades;
}

Trade OrderBook::executeTrade(OrderPtr buyOrder, OrderPtr sellOrder,
                               double price, double quantity) {
    buyOrder->filledQuantity += quantity;
    sellOrder->filledQuantity += quantity;

    if (buyOrder->isFilled()) {
        buyOrder->status = OrderStatus::FILLED;
    } else if (buyOrder->filledQuantity > 0) {
        buyOrder->status = OrderStatus::PARTIAL;
    }

    if (sellOrder->isFilled()) {
        sellOrder->status = OrderStatus::FILLED;
    } else if (sellOrder->filledQuantity > 0) {
        sellOrder->status = OrderStatus::PARTIAL;
    }

    return Trade{
        buyOrder->id,
        sellOrder->id,
        price,
        quantity,
        std::chrono::system_clock::now()
    };
}

bool OrderBook::cancelOrder(uint64_t orderId) {
    std::lock_guard<std::mutex> lock(mutex_);

    auto it = orders_.find(orderId);
    if (it == orders_.end()) {
        return false;
    }

    auto order = it->second;

    // Remove from bid/ask book
    auto& book = (order->side == OrderSide::BUY) ? bids_ : asks_;
    auto priceLevel = book.find(order->price);

    if (priceLevel != book.end()) {
        auto& orders = priceLevel->second;
        orders.erase(
            std::remove(orders.begin(), orders.end(), order),
            orders.end()
        );

        if (orders.empty()) {
            book.erase(priceLevel);
        }
    }

    order->status = OrderStatus::CANCELLED;
    orders_.erase(it);

    return true;
}

double OrderBook::getBestBid() const {
    std::lock_guard<std::mutex> lock(mutex_);
    return bids_.empty() ? 0.0 : bids_.begin()->first;
}

double OrderBook::getBestAsk() const {
    std::lock_guard<std::mutex> lock(mutex_);
    return asks_.empty() ? 0.0 : asks_.begin()->first;
}

std::map<double, double> OrderBook::getBidDepth(int levels) const {
    std::lock_guard<std::mutex> lock(mutex_);
    std::map<double, double> depth;

    int count = 0;
    for (const auto& [price, orders] : bids_) {
        if (count++ >= levels) break;

        double totalQuantity = 0.0;
        for (const auto& order : orders) {
            totalQuantity += order->getRemainingQuantity();
        }
        depth[price] = totalQuantity;
    }

    return depth;
}

std::map<double, double> OrderBook::getAskDepth(int levels) const {
    std::lock_guard<std::mutex> lock(mutex_);
    std::map<double, double> depth;

    int count = 0;
    for (const auto& [price, orders] : asks_) {
        if (count++ >= levels) break;

        double totalQuantity = 0.0;
        for (const auto& order : orders) {
            totalQuantity += order->getRemainingQuantity();
        }
        depth[price] = totalQuantity;
    }

    return depth;
}

std::vector<OrderPtr> OrderBook::getUserOrders(const std::string& userId) const {
    std::lock_guard<std::mutex> lock(mutex_);
    std::vector<OrderPtr> userOrders;

    for (const auto& [id, order] : orders_) {
        if (order->userId == userId) {
            userOrders.push_back(order);
        }
    }

    return userOrders;
}

} // namespace DEX
