#include "../include/ReputationCalculator.hpp"
#include <iostream>
#include <iomanip>

using namespace Reputation;

void printProfile(const std::string& name, const DeveloperMetrics& metrics) {
    std::cout << "\n=== Developer Profile: " << name << " ===" << std::endl;
    std::cout << "GitHub: @" << metrics.username << std::endl;
    std::cout << std::string(50, '-') << std::endl;

    std::cout << "\n📊 Contribution Statistics:" << std::endl;
    std::cout << "  Commits:      " << metrics.totalCommits << std::endl;
    std::cout << "  Pull Requests: " << metrics.totalPRs << std::endl;
    std::cout << "  Issues:       " << metrics.totalIssues << std::endl;
    std::cout << "  Code Reviews:  " << metrics.totalReviews << std::endl;
    std::cout << "  Total Stars:   " << metrics.totalStars << std::endl;

    std::cout << "\n⭐ Reputation Scores:" << std::endl;
    std::cout << std::fixed << std::setprecision(2);
    std::cout << "  Activity Score:  " << metrics.activityScore << "/100" << std::endl;
    std::cout << "  Quality Score:   " << metrics.qualityScore << "/100" << std::endl;
    std::cout << "  Impact Score:    " << metrics.impactScore << "/100" << std::endl;
    std::cout << "\n  🏆 REPUTATION: " << metrics.reputationScore << "/100" << std::endl;

    ReputationCalculator calc;
    std::cout << "  Tier: " << calc.getReputationTier(metrics.reputationScore) << std::endl;

    std::cout << "\n🔤 Language Breakdown:" << std::endl;
    for (const auto& [lang, count] : metrics.languageBreakdown) {
        std::cout << "  " << lang << ": " << count << " contributions" << std::endl;
    }

    std::cout << "\n📦 Repositories (" << metrics.repositories.size() << " total):" << std::endl;
    int shown = 0;
    for (const auto& [name, repo] : metrics.repositories) {
        if (shown++ >= 5) {
            std::cout << "  ... and " << (metrics.repositories.size() - 5) << " more" << std::endl;
            break;
        }
        std::cout << "  " << repo.owner << "/" << repo.name
                  << " (" << repo.stars << " ⭐)" << std::endl;
    }
}

int main() {
    std::cout << "\n╔══════════════════════════════════════════════════════════╗" << std::endl;
    std::cout << "║   DEVELOPER REPUTATION SYSTEM - Demo                    ║" << std::endl;
    std::cout << "╚══════════════════════════════════════════════════════════╝\n" << std::endl;

    Reputation::ReputationCalculator calculator;

    // Simulate Developer 1: Active contributor
    std::cout << "Simulating Developer Profiles...\n" << std::endl;

    DeveloperMetrics dev1 = {};
    dev1.username = "alice_blockchain";
    dev1.totalCommits = 0;
    dev1.totalPRs = 0;
    dev1.totalIssues = 0;
    dev1.totalReviews = 0;
    dev1.totalStars = 0;
    dev1.activityScore = 0.0;
    dev1.qualityScore = 0.0;
    dev1.impactScore = 0.0;
    dev1.reputationScore = 0.0;

    // Add repositories
    Repository ethereum = {
        "ethereum", "ethereum", "Go", 45000, 12000, 800, true, 0.0
    };
    ethereum.significance = calculator.calculateRepoSignificance(ethereum);

    Repository solidity = {
        "solidity", "ethereum", "C++", 18000, 5000, 400, true, 0.0
    };
    solidity.significance = calculator.calculateRepoSignificance(solidity);

    // Add contributions
    auto now = std::chrono::system_clock::now();

    // Recent high-quality PR
    Contribution pr1 = {
        "abc123", ContributionType::PULL_REQUEST, "ethereum/ethereum",
        now - std::chrono::hours(24 * 5), 450, 80, 8, true, true, 0.0
    };
    calculator.updateMetrics(dev1, pr1, ethereum);

    // Commit with tests
    Contribution commit1 = {
        "def456", ContributionType::COMMIT, "ethereum/solidity",
        now - std::chrono::hours(24 * 15), 200, 50, 4, true, false, 0.0
    };
    calculator.updateMetrics(dev1, commit1, solidity);

    // Code review
    Contribution review1 = {
        "ghi789", ContributionType::CODE_REVIEW, "ethereum/ethereum",
        now - std::chrono::hours(24 * 3), 0, 0, 0, false, false, 0.0
    };
    calculator.updateMetrics(dev1, review1, ethereum);

    // Add more contributions
    for (int i = 0; i < 15; i++) {
        Contribution c = {
            "commit_" + std::to_string(i), ContributionType::COMMIT,
            (i % 2 == 0) ? "ethereum/ethereum" : "ethereum/solidity",
            now - std::chrono::hours(24 * (7 + i * 2)),
            100 + (i * 30), 20 + (i * 10), 2 + i, (i % 3 == 0), (i % 4 == 0), 0.0
        };
        calculator.updateMetrics(dev1, c, (i % 2 == 0) ? ethereum : solidity);
    }

    printProfile("Alice", dev1);

    // Simulate Developer 2: Quality-focused contributor
    DeveloperMetrics dev2 = {};
    dev2.username = "bob_defi";
    dev2.totalCommits = 0;
    dev2.totalPRs = 0;
    dev2.totalIssues = 0;
    dev2.totalReviews = 0;
    dev2.totalStars = 0;
    dev2.activityScore = 0.0;
    dev2.qualityScore = 0.0;
    dev2.impactScore = 0.0;
    dev2.reputationScore = 0.0;

    Repository uniswap = {
        "uniswap-v3-core", "Uniswap", "Solidity", 25000, 8000, 300, true, 0.0
    };
    uniswap.significance = calculator.calculateRepoSignificance(uniswap);

    // High-quality PRs with comprehensive tests
    for (int i = 0; i < 8; i++) {
        Contribution pr = {
            "pr_" + std::to_string(i), ContributionType::PULL_REQUEST,
            "Uniswap/uniswap-v3-core",
            now - std::chrono::hours(24 * (10 + i * 5)),
            300 + (i * 50), 100 + (i * 20), 5 + i, true, true, 0.0
        };
        calculator.updateMetrics(dev2, pr, uniswap);
    }

    // Code reviews
    for (int i = 0; i < 12; i++) {
        Contribution review = {
            "review_" + std::to_string(i), ContributionType::CODE_REVIEW,
            "Uniswap/uniswap-v3-core",
            now - std::chrono::hours(24 * (2 + i)), 0, 0, 0, false, false, 0.0
        };
        calculator.updateMetrics(dev2, review, uniswap);
    }

    printProfile("Bob", dev2);

    // Comparison
    std::cout << "\n\n╔══════════════════════════════════════════════════════════╗" << std::endl;
    std::cout << "║   REPUTATION COMPARISON                                  ║" << std::endl;
    std::cout << "╚══════════════════════════════════════════════════════════╝\n" << std::endl;

    std::cout << std::fixed << std::setprecision(2);
    std::cout << "Developer          | Reputation | Activity | Quality | Impact | Tier" << std::endl;
    std::cout << std::string(85, '-') << std::endl;

    auto printRow = [&](const std::string& name, const DeveloperMetrics& m) {
        std::cout << std::left << std::setw(19) << name
                  << "| " << std::setw(11) << m.reputationScore
                  << "| " << std::setw(9) << m.activityScore
                  << "| " << std::setw(8) << m.qualityScore
                  << "| " << std::setw(7) << m.impactScore
                  << "| " << calculator.getReputationTier(m.reputationScore)
                  << std::endl;
    };

    printRow("@alice_blockchain", dev1);
    printRow("@bob_defi", dev2);

    std::cout << "\n\n💡 Scoring Insights:" << std::endl;
    std::cout << "  • Alice has high activity (many commits) but moderate quality" << std::endl;
    std::cout << "  • Bob focuses on quality (tests + docs) with strategic PRs" << std::endl;
    std::cout << "  • Both contribute to significant blockchain projects (high impact)" << std::endl;
    std::cout << "  • Recent contributions weigh more heavily in the score" << std::endl;

    std::cout << "\n🎯 Use Cases:" << std::endl;
    std::cout << "  1. Hiring: Verify candidate skills via on-chain reputation" << std::endl;
    std::cout << "  2. Grants: Award funding based on proven contributions" << std::endl;
    std::cout << "  3. Access: Gate community features by reputation tier" << std::endl;
    std::cout << "  4. Recognition: Public leaderboards and achievements" << std::endl;

    std::cout << "\n" << std::endl;

    return 0;
}
