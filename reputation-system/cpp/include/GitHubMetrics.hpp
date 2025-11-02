#pragma once

#include <string>
#include <vector>
#include <map>
#include <chrono>

namespace Reputation {

// GitHub contribution types
enum class ContributionType {
    COMMIT,
    PULL_REQUEST,
    ISSUE,
    CODE_REVIEW,
    DISCUSSION
};

// Repository metadata
struct Repository {
    std::string name;
    std::string owner;
    std::string language;
    int stars;
    int forks;
    int contributors;
    bool isBlockchain;
    double significance; // Calculated score
};

// Contribution record
struct Contribution {
    std::string hash;
    ContributionType type;
    std::string repository;
    std::chrono::system_clock::time_point timestamp;
    int linesAdded;
    int linesDeleted;
    int filesChanged;
    bool hasTests;
    bool hasDocumentation;
    double impact; // Calculated impact score
};

// Developer metrics
struct DeveloperMetrics {
    std::string username;
    int totalCommits;
    int totalPRs;
    int totalIssues;
    int totalReviews;
    int totalStars; // Sum of stars from contributed repos
    double activityScore;
    double qualityScore;
    double impactScore;
    double reputationScore; // Final score

    std::vector<Contribution> contributions;
    std::map<std::string, int> languageBreakdown;
    std::map<std::string, Repository> repositories;
};

// Scoring weights
struct ScoringWeights {
    double commitWeight = 1.0;
    double prWeight = 3.0;
    double issueWeight = 1.5;
    double reviewWeight = 2.0;
    double testWeight = 1.5;
    double docWeight = 1.2;
    double repoSignificanceMultiplier = 2.0;
};

} // namespace Reputation
