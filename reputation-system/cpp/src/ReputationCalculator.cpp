#include "../include/ReputationCalculator.hpp"
#include <cmath>
#include <algorithm>
#include <numeric>

namespace Reputation {

ReputationCalculator::ReputationCalculator(const ScoringWeights& weights)
    : weights_(weights) {}

double ReputationCalculator::calculateRepoSignificance(const Repository& repo) const {
    // Logarithmic scaling for stars and forks
    double starScore = std::log10(repo.stars + 1) * 10.0;
    double forkScore = std::log10(repo.forks + 1) * 8.0;
    double contributorScore = std::log10(repo.contributors + 1) * 5.0;

    // Blockchain projects get a boost
    double blockchainBonus = repo.isBlockchain ? 20.0 : 0.0;

    double rawScore = starScore + forkScore + contributorScore + blockchainBonus;
    return normalizeScore(rawScore);
}

double ReputationCalculator::calculateContributionImpact(
    const Contribution& contrib,
    const Repository& repo) const {

    // Base impact from code changes
    double linesImpact = std::log10(contrib.linesAdded + contrib.linesDeleted + 1) * 5.0;
    double filesImpact = std::log10(contrib.filesChanged + 1) * 3.0;

    // Quality multipliers
    double testMultiplier = contrib.hasTests ? 1.5 : 1.0;
    double docMultiplier = contrib.hasDocumentation ? 1.2 : 1.0;

    // Contribution type multiplier
    double typeMultiplier = 1.0;
    switch (contrib.type) {
        case ContributionType::COMMIT:
            typeMultiplier = weights_.commitWeight;
            break;
        case ContributionType::PULL_REQUEST:
            typeMultiplier = weights_.prWeight;
            break;
        case ContributionType::ISSUE:
            typeMultiplier = weights_.issueWeight;
            break;
        case ContributionType::CODE_REVIEW:
            typeMultiplier = weights_.reviewWeight;
            break;
        default:
            typeMultiplier = 1.0;
    }

    // Time decay (more recent = higher value)
    double decayFactor = calculateDecayFactor(contrib.timestamp);

    // Repository significance multiplier
    double repoMultiplier = 1.0 + (repo.significance / 100.0) * weights_.repoSignificanceMultiplier;

    double rawImpact = (linesImpact + filesImpact) *
                       testMultiplier *
                       docMultiplier *
                       typeMultiplier *
                       decayFactor *
                       repoMultiplier;

    return normalizeScore(rawImpact);
}

double ReputationCalculator::calculateActivityScore(const DeveloperMetrics& metrics) const {
    if (metrics.contributions.empty()) {
        return 0.0;
    }

    // Frequency score
    double totalContributions = metrics.totalCommits +
                               metrics.totalPRs +
                               metrics.totalIssues +
                               metrics.totalReviews;

    double frequencyScore = std::log10(totalContributions + 1) * 15.0;

    // Consistency score (based on time distribution)
    auto now = std::chrono::system_clock::now();
    auto thirtyDaysAgo = now - std::chrono::hours(24 * 30);
    auto ninetyDaysAgo = now - std::chrono::hours(24 * 90);

    int recentContribs = 0;
    int mediumContribs = 0;

    for (const auto& contrib : metrics.contributions) {
        if (contrib.timestamp > thirtyDaysAgo) {
            recentContribs++;
        } else if (contrib.timestamp > ninetyDaysAgo) {
            mediumContribs++;
        }
    }

    double consistencyScore = (recentContribs * 2.0 + mediumContribs) / 10.0;

    double rawScore = frequencyScore + consistencyScore;
    return normalizeScore(rawScore);
}

double ReputationCalculator::calculateQualityScore(const DeveloperMetrics& metrics) const {
    if (metrics.contributions.empty()) {
        return 0.0;
    }

    // Test coverage
    int contribsWithTests = std::count_if(
        metrics.contributions.begin(),
        metrics.contributions.end(),
        [](const Contribution& c) { return c.hasTests; }
    );

    double testRatio = static_cast<double>(contribsWithTests) / metrics.contributions.size();
    double testScore = testRatio * 30.0 * weights_.testWeight;

    // Documentation
    int contribsWithDocs = std::count_if(
        metrics.contributions.begin(),
        metrics.contributions.end(),
        [](const Contribution& c) { return c.hasDocumentation; }
    );

    double docRatio = static_cast<double>(contribsWithDocs) / metrics.contributions.size();
    double docScore = docRatio * 25.0 * weights_.docWeight;

    // Code review participation
    double reviewScore = std::log10(metrics.totalReviews + 1) * 10.0 * weights_.reviewWeight;

    // PR acceptance rate (assuming all PRs in our data are merged)
    double prScore = std::log10(metrics.totalPRs + 1) * 15.0;

    double rawScore = testScore + docScore + reviewScore + prScore;
    return normalizeScore(rawScore);
}

double ReputationCalculator::calculateImpactScore(const DeveloperMetrics& metrics) const {
    if (metrics.contributions.empty()) {
        return 0.0;
    }

    // Average impact of contributions
    double totalImpact = std::accumulate(
        metrics.contributions.begin(),
        metrics.contributions.end(),
        0.0,
        [](double sum, const Contribution& c) { return sum + c.impact; }
    );

    double avgImpact = totalImpact / metrics.contributions.size();

    // Repository significance (sum of stars from contributed repos)
    double repoImpact = std::log10(metrics.totalStars + 1) * 20.0;

    // Number of different repositories
    double diversityBonus = std::log10(metrics.repositories.size() + 1) * 10.0;

    double rawScore = avgImpact + repoImpact + diversityBonus;
    return normalizeScore(rawScore);
}

double ReputationCalculator::calculateReputationScore(const DeveloperMetrics& metrics) const {
    // Weighted combination of all scores
    double activityWeight = 0.25;
    double qualityWeight = 0.35;
    double impactWeight = 0.40;

    double finalScore = (metrics.activityScore * activityWeight +
                        metrics.qualityScore * qualityWeight +
                        metrics.impactScore * impactWeight);

    return std::clamp(finalScore, 0.0, 100.0);
}

void ReputationCalculator::updateMetrics(
    DeveloperMetrics& metrics,
    const Contribution& contrib,
    const Repository& repo) {

    // Update contribution counts
    switch (contrib.type) {
        case ContributionType::COMMIT:
            metrics.totalCommits++;
            break;
        case ContributionType::PULL_REQUEST:
            metrics.totalPRs++;
            break;
        case ContributionType::ISSUE:
            metrics.totalIssues++;
            break;
        case ContributionType::CODE_REVIEW:
            metrics.totalReviews++;
            break;
        default:
            break;
    }

    // Add contribution with calculated impact
    Contribution contribWithImpact = contrib;
    contribWithImpact.impact = calculateContributionImpact(contrib, repo);
    metrics.contributions.push_back(contribWithImpact);

    // Update repository tracking
    if (metrics.repositories.find(repo.name) == metrics.repositories.end()) {
        metrics.repositories[repo.name] = repo;
        metrics.totalStars += repo.stars;
    }

    // Update language breakdown
    if (!repo.language.empty()) {
        metrics.languageBreakdown[repo.language]++;
    }

    // Recalculate all scores
    metrics.activityScore = calculateActivityScore(metrics);
    metrics.qualityScore = calculateQualityScore(metrics);
    metrics.impactScore = calculateImpactScore(metrics);
    metrics.reputationScore = calculateReputationScore(metrics);
}

std::string ReputationCalculator::getReputationTier(double score) const {
    if (score >= 90.0) return "Legendary";
    if (score >= 80.0) return "Expert";
    if (score >= 70.0) return "Advanced";
    if (score >= 60.0) return "Proficient";
    if (score >= 50.0) return "Competent";
    if (score >= 40.0) return "Intermediate";
    if (score >= 30.0) return "Developing";
    if (score >= 20.0) return "Beginner";
    return "Novice";
}

void ReputationCalculator::setWeights(const ScoringWeights& weights) {
    weights_ = weights;
}

double ReputationCalculator::calculateDecayFactor(
    const std::chrono::system_clock::time_point& timestamp) const {

    auto now = std::chrono::system_clock::now();
    auto age = std::chrono::duration_cast<std::chrono::hours>(now - timestamp).count();

    // Decay over 2 years (17520 hours)
    const double maxAge = 17520.0;
    double decayRate = 0.5; // Half-life at 1 year

    if (age >= maxAge) {
        return 0.1; // Minimum factor
    }

    // Exponential decay
    double factor = std::exp(-decayRate * age / (maxAge / 2));
    return std::max(0.1, factor);
}

double ReputationCalculator::normalizeScore(double rawScore) const {
    // Use sigmoid-like function to normalize to 0-100
    double normalized = (100.0 * rawScore) / (rawScore + 50.0);
    return std::clamp(normalized, 0.0, 100.0);
}

} // namespace Reputation
