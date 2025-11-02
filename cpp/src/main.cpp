#include "../include/MatchingEngine.hpp"
#include <iostream>
#include <iomanip>

using namespace DEX;

void printMarketData(const MatchingEngine::MarketData& data) {
    std::cout << "\n=== Market Data ===" << std::endl;
    std::cout << "Best Bid: " << data.bestBid << std::endl;
    std::cout << "Best Ask: " << data.bestAsk << std::endl;
    std::cout << "Spread: " << data.spread << std::endl;

    std::cout << "\nBid Depth:" << std::endl;
    for (const auto& [price, quantity] : data.bidDepth) {
        std::cout << "  Price: " << std::setw(10) << price
                  << " | Quantity: " << quantity << std::endl;
    }

    std::cout << "\nAsk Depth:" << std::endl;
    for (const auto& [price, quantity] : data.askDepth) {
        std::cout << "  Price: " << std::setw(10) << price
                  << " | Quantity: " << quantity << std::endl;
    }
}

void printTrades(const std::vector<Trade>& trades) {
    if (trades.empty()) {
        std::cout << "No trades executed." << std::endl;
        return;
    }

    std::cout << "\n=== Executed Trades ===" << std::endl;
    for (const auto& trade : trades) {
        std::cout << "Trade: Buy Order #" << trade.buyOrderId
                  << " <-> Sell Order #" << trade.sellOrderId
                  << " | Price: " << trade.price
                  << " | Quantity: " << trade.quantity << std::endl;
    }
}

int main() {
    std::cout << "=== DEX Trading Engine Demo ===" << std::endl;

    // Create matching engine
    MatchingEngine engine;

    // Add trading pair
    engine.addTradingPair("ETH/USDT");
    std::cout << "\nAdded trading pair: ETH/USDT" << std::endl;

    // Submit some limit buy orders
    std::cout << "\n--- Submitting Buy Orders ---" << std::endl;
    auto trades1 = engine.submitOrder("user1", "ETH/USDT", OrderSide::BUY,
                                      OrderType::LIMIT, 2000.0, 1.5);
    std::cout << "User1: BUY 1.5 ETH @ 2000 USDT" << std::endl;

    auto trades2 = engine.submitOrder("user2", "ETH/USDT", OrderSide::BUY,
                                      OrderType::LIMIT, 1990.0, 2.0);
    std::cout << "User2: BUY 2.0 ETH @ 1990 USDT" << std::endl;

    auto trades3 = engine.submitOrder("user3", "ETH/USDT", OrderSide::BUY,
                                      OrderType::LIMIT, 1995.0, 1.0);
    std::cout << "User3: BUY 1.0 ETH @ 1995 USDT" << std::endl;

    // Submit some limit sell orders
    std::cout << "\n--- Submitting Sell Orders ---" << std::endl;
    auto trades4 = engine.submitOrder("user4", "ETH/USDT", OrderSide::SELL,
                                      OrderType::LIMIT, 2010.0, 1.0);
    std::cout << "User4: SELL 1.0 ETH @ 2010 USDT" << std::endl;

    auto trades5 = engine.submitOrder("user5", "ETH/USDT", OrderSide::SELL,
                                      OrderType::LIMIT, 2020.0, 2.5);
    std::cout << "User5: SELL 2.5 ETH @ 2020 USDT" << std::endl;

    // Print market data
    auto marketData = engine.getMarketData("ETH/USDT");
    printMarketData(marketData);

    // Submit a matching order
    std::cout << "\n--- Executing Market Order ---" << std::endl;
    std::cout << "User6: SELL 1.2 ETH @ MARKET" << std::endl;
    auto trades6 = engine.submitOrder("user6", "ETH/USDT", OrderSide::SELL,
                                      OrderType::MARKET, 0.0, 1.2);
    printTrades(trades6);

    // Print updated market data
    marketData = engine.getMarketData("ETH/USDT");
    printMarketData(marketData);

    // Statistics
    std::cout << "\n=== Engine Statistics ===" << std::endl;
    std::cout << "Total orders: " << engine.getTotalOrders() << std::endl;
    std::cout << "Trading pairs: " << engine.getTradingPairCount() << std::endl;

    return 0;
}
