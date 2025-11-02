# Developer Reputation System 🏆

Quantitative assessment of developer quality based on contributions to significant open-source blockchain repositories.

## Overview

This system provides a comprehensive, data-driven approach to evaluating blockchain developers through:

- **Activity Analysis**: Commit frequency, PR submissions, issue management
- **Quality Metrics**: Test coverage, documentation, code review participation
- **Impact Assessment**: Repository significance, contribution reach, community influence
- **On-chain Storage**: Immutable reputation scores stored on blockchain

## Key Features

### C++ Analytics Engine
- High-performance data processing
- Sophisticated scoring algorithms
- Multi-dimensional reputation calculation
- Time-decay factors for recent activity

### Smart Contract Integration
- On-chain reputation storage
- Tiered developer classification
- Verifiable credentials
- Leaderboard functionality

### Comprehensive Scoring

**Reputation Score Formula:**
```
Reputation = (Activity × 0.25) + (Quality × 0.35) + (Impact × 0.40)
```

**Activity Score** (25% weight):
- Commit frequency
- PR submissions
- Issue management
- Contribution consistency

**Quality Score** (35% weight):
- Test coverage
- Documentation
- Code review participation
- PR acceptance rate

**Impact Score** (40% weight):
- Repository significance (stars/forks)
- Contribution reach
- Community engagement
- Technology diversity

## Reputation Tiers

| Tier | Score Range | Description |
|------|-------------|-------------|
| 🌟 Legendary | 90-100 | Elite contributors to major projects |
| 🔥 Expert | 80-89 | Highly skilled with significant impact |
| 💎 Advanced | 70-79 | Experienced, consistent contributors |
| ⚡ Proficient | 60-69 | Solid track record |
| ✨ Competent | 50-59 | Regular contributor |
| 📈 Intermediate | 40-49 | Growing portfolio |
| 🌱 Developing | 30-39 | Building experience |
| 🎯 Beginner | 20-29 | Starting journey |
| 🌟 Novice | 0-19 | New to open source |

## Project Structure

```
reputation-system/
├── cpp/                       # C++ Analytics Engine
│   ├── include/
│   │   ├── GitHubMetrics.hpp  # Data structures
│   │   └── ReputationCalculator.hpp
│   └── src/
│       ├── ReputationCalculator.cpp
│       └── demo.cpp           # Demo application
├── contracts/                 # Smart Contracts
│   └── src/
│       └── DeveloperReputation.sol
├── web3/                      # Web3 Integration
│   └── src/
│       └── ReputationClient.js
└── docs/                      # Documentation
```

## Quick Start

### Build C++ Engine

```bash
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make
./reputation_demo
```

### Deploy Smart Contract

```bash
npm install
npx hardhat compile
npx hardhat run scripts/deploy.js --network localhost
```

## Usage Examples

### C++ API

```cpp
#include "ReputationCalculator.hpp"

using namespace Reputation;

// Create calculator
ReputationCalculator calc;

// Create developer profile
DeveloperMetrics metrics;
metrics.username = "satoshi";

// Add repository
Repository bitcoin = {
    "bitcoin", "bitcoin", "C++",
    75000,  // stars
    35000,  // forks
    1000,   // contributors
    true,   // is blockchain
    0.0     // significance (calculated)
};
bitcoin.significance = calc.calculateRepoSignificance(bitcoin);

// Add contribution
Contribution commit = {
    "abc123",
    ContributionType::COMMIT,
    "bitcoin/bitcoin",
    std::chrono::system_clock::now(),
    500,    // lines added
    100,    // lines deleted
    10,     // files changed
    true,   // has tests
    true,   // has documentation
    0.0     // impact (calculated)
};

// Update metrics
calc.updateMetrics(metrics, commit, bitcoin);

// Get reputation score
std::cout << "Reputation: " << metrics.reputationScore << "/100\n";
std::cout << "Tier: " << calc.getReputationTier(metrics.reputationScore) << "\n";
```

### Smart Contract API

```solidity
// Create profile
await reputation.createProfile(
    developerAddress,
    "satoshi"
);

// Update reputation
await reputation.updateReputation(
    developerAddress,
    8500,  // reputation score (85.00)
    7500,  // activity score
    9000,  // quality score
    9500,  // impact score
    250,   // total contributions
    75000  // total stars
);

// Get profile
const profile = await reputation.getProfile(developerAddress);
console.log(`Tier: ${profile.tier}`);
console.log(`Score: ${profile.reputationScore / 100}`);

// Get top developers
const [devs, scores] = await reputation.getTopDevelopers(10);
```

### JavaScript Client

```javascript
const ReputationClient = require('./web3/src/ReputationClient');

const client = new ReputationClient(contractAddress, abi, provider);

// Get developer profile
const profile = await client.getProfile(address);
console.log(`${profile.githubUsername}: ${profile.reputationScore}/100`);

// Listen for updates
client.onProfileUpdated((address, score, tier) => {
    console.log(`${address} updated to tier ${tier}`);
});
```

## Scoring Algorithm Details

### Repository Significance

```
significance = log10(stars + 1) × 10
             + log10(forks + 1) × 8
             + log10(contributors + 1) × 5
             + (isBlockchain ? 20 : 0)
```

### Contribution Impact

```
impact = (log10(lines) × 5 + log10(files) × 3)
       × testMultiplier
       × docMultiplier
       × typeWeight
       × timeDe cayFactor
       × repoSignificance
```

### Time Decay

Recent contributions weighted more heavily:
- Last 30 days: 1.0x weight
- 30-90 days: 0.7x weight
- 90-365 days: 0.4x weight
- 1-2 years: 0.2x weight
- 2+ years: 0.1x weight (minimum)

## Use Cases

### 🎯 Hiring & Recruitment
- Verify candidate skills with quantitative data
- Compare applicants objectively
- Identify specialists in specific technologies

### 💰 Grants & Funding
- Award based on proven contributions
- Track grantee progress
- Measure return on investment

### 🔐 Access Control
- Gate community features by tier
- Whitelist for token sales
- DAO voting power weights

### 🏅 Recognition & Gamification
- Public leaderboards
- Achievement badges
- Community reputation

### 🤝 Collaboration Matching
- Find contributors by expertise
- Match projects with developers
- Form teams based on complementary skills

## Security Considerations

- **Oracle Trust**: Reputation updates require ORACLE_ROLE
- **Verification**: Manual verification for high-stakes use cases
- **Gaming Resistance**: Multiple factors prevent manipulation
- **Time Decay**: Prevents resting on past achievements
- **Quality Over Quantity**: Tests and docs weighted heavily

## Roadmap

- [ ] GitHub API integration for auto-updates
- [ ] Multi-platform support (GitLab, Bitbucket)
- [ ] NFT badges for tier achievements
- [ ] Decentralized oracle network
- [ ] Advanced ML-based scoring
- [ ] Privacy-preserving options
- [ ] Cross-chain reputation
- [ ] Mobile app

## Contributing

Contributions welcome! This is meta - contribute to improve the contributor scoring system!

1. Fork the repository
2. Create feature branch
3. Add tests
4. Submit PR

## License

MIT License

## Contact

For questions and feedback, open an issue on GitHub.

---

**Note**: This system provides quantitative metrics but should be used alongside qualitative assessment for important decisions.
