#pragma once

#include "GitHubMetrics.hpp"
#include <memory>
#include <optional>

namespace Reputation {

class ReputationCalculator {
public:
    explicit ReputationCalculator(const ScoringWeights& weights = ScoringWeights());

    // Calculate repository significance
    double calculateRepoSignificance(const Repository& repo) const;

    // Calculate contribution impact
    double calculateContributionImpact(const Contribution& contrib,
                                       const Repository& repo) const;

    // Calculate activity score (frequency and consistency)
    double calculateActivityScore(const DeveloperMetrics& metrics) const;

    // Calculate quality score (tests, docs, reviews)
    double calculateQualityScore(const DeveloperMetrics& metrics) const;

    // Calculate impact score (significance of contributions)
    double calculateImpactScore(const DeveloperMetrics& metrics) const;

    // Calculate final reputation score
    double calculateReputationScore(const DeveloperMetrics& metrics) const;

    // Update developer metrics with new contribution
    void updateMetrics(DeveloperMetrics& metrics,
                      const Contribution& contrib,
                      const Repository& repo);

    // Get reputation tier based on score
    std::string getReputationTier(double score) const;

    // Set custom weights
    void setWeights(const ScoringWeights& weights);

private:
    ScoringWeights weights_;

    // Helper: Calculate time-based decay factor
    double calculateDecayFactor(
        const std::chrono::system_clock::time_point& timestamp) const;

    // Helper: Normalize score to 0-100 range
    double normalizeScore(double rawScore) const;
};

} // namespace Reputation
