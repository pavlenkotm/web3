// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title DeveloperReputation
 * @dev On-chain storage and management of developer reputation scores
 */
contract DeveloperReputation is AccessControl, ReentrancyGuard {
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // Reputation tiers
    enum Tier { Novice, Beginner, Developing, Intermediate, Competent, Proficient, Advanced, Expert, Legendary }

    // Developer profile
    struct Profile {
        string githubUsername;
        uint256 reputationScore;      // 0-10000 (100.00 with 2 decimals)
        uint256 activityScore;
        uint256 qualityScore;
        uint256 impactScore;
        uint256 totalContributions;
        uint256 totalStars;
        uint256 lastUpdated;
        Tier tier;
        bool verified;
    }

    // Contribution record
    struct ContributionRecord {
        string repository;
        uint256 timestamp;
        uint256 impactScore;
        string contributionType;
    }

    // Mapping from address to profile
    mapping(address => Profile) public profiles;

    // Mapping from address to contributions
    mapping(address => ContributionRecord[]) public contributions;

    // Mapping from GitHub username to address
    mapping(string => address) public githubToAddress;

    // List of verified developers
    address[] public verifiedDevelopers;

    // Events
    event ProfileCreated(address indexed developer, string githubUsername);
    event ProfileUpdated(address indexed developer, uint256 newScore, Tier newTier);
    event ContributionAdded(address indexed developer, string repository, uint256 impactScore);
    event ProfileVerified(address indexed developer);
    event TierUpgraded(address indexed developer, Tier oldTier, Tier newTier);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(ORACLE_ROLE, msg.sender);
    }

    /**
     * @dev Create a new developer profile
     */
    function createProfile(address developer, string memory githubUsername)
        external
        onlyRole(ORACLE_ROLE)
    {
        require(bytes(profiles[developer].githubUsername).length == 0, "Profile already exists");
        require(githubToAddress[githubUsername] == address(0), "GitHub username already registered");

        profiles[developer] = Profile({
            githubUsername: githubUsername,
            reputationScore: 0,
            activityScore: 0,
            qualityScore: 0,
            impactScore: 0,
            totalContributions: 0,
            totalStars: 0,
            lastUpdated: block.timestamp,
            tier: Tier.Novice,
            verified: false
        });

        githubToAddress[githubUsername] = developer;

        emit ProfileCreated(developer, githubUsername);
    }

    /**
     * @dev Update developer reputation score
     */
    function updateReputation(
        address developer,
        uint256 reputationScore,
        uint256 activityScore,
        uint256 qualityScore,
        uint256 impactScore,
        uint256 totalContributions,
        uint256 totalStars
    ) external onlyRole(ORACLE_ROLE) {
        require(bytes(profiles[developer].githubUsername).length > 0, "Profile does not exist");
        require(reputationScore <= 10000, "Score exceeds maximum");

        Profile storage profile = profiles[developer];
        Tier oldTier = profile.tier;

        profile.reputationScore = reputationScore;
        profile.activityScore = activityScore;
        profile.qualityScore = qualityScore;
        profile.impactScore = impactScore;
        profile.totalContributions = totalContributions;
        profile.totalStars = totalStars;
        profile.lastUpdated = block.timestamp;

        // Update tier based on score
        Tier newTier = calculateTier(reputationScore);
        profile.tier = newTier;

        emit ProfileUpdated(developer, reputationScore, newTier);

        if (newTier != oldTier) {
            emit TierUpgraded(developer, oldTier, newTier);
        }
    }

    /**
     * @dev Add a contribution record
     */
    function addContribution(
        address developer,
        string memory repository,
        uint256 impactScore,
        string memory contributionType
    ) external onlyRole(ORACLE_ROLE) {
        require(bytes(profiles[developer].githubUsername).length > 0, "Profile does not exist");

        contributions[developer].push(ContributionRecord({
            repository: repository,
            timestamp: block.timestamp,
            impactScore: impactScore,
            contributionType: contributionType
        }));

        emit ContributionAdded(developer, repository, impactScore);
    }

    /**
     * @dev Verify a developer profile
     */
    function verifyProfile(address developer) external onlyRole(ADMIN_ROLE) {
        require(bytes(profiles[developer].githubUsername).length > 0, "Profile does not exist");
        require(!profiles[developer].verified, "Already verified");

        profiles[developer].verified = true;
        verifiedDevelopers.push(developer);

        emit ProfileVerified(developer);
    }

    /**
     * @dev Calculate tier based on reputation score
     */
    function calculateTier(uint256 score) public pure returns (Tier) {
        if (score >= 9000) return Tier.Legendary;
        if (score >= 8000) return Tier.Expert;
        if (score >= 7000) return Tier.Advanced;
        if (score >= 6000) return Tier.Proficient;
        if (score >= 5000) return Tier.Competent;
        if (score >= 4000) return Tier.Intermediate;
        if (score >= 3000) return Tier.Developing;
        if (score >= 2000) return Tier.Beginner;
        return Tier.Novice;
    }

    /**
     * @dev Get developer profile
     */
    function getProfile(address developer) external view returns (Profile memory) {
        return profiles[developer];
    }

    /**
     * @dev Get contribution count for developer
     */
    function getContributionCount(address developer) external view returns (uint256) {
        return contributions[developer].length;
    }

    /**
     * @dev Get specific contribution
     */
    function getContribution(address developer, uint256 index)
        external
        view
        returns (ContributionRecord memory)
    {
        require(index < contributions[developer].length, "Index out of bounds");
        return contributions[developer][index];
    }

    /**
     * @dev Get all verified developers
     */
    function getVerifiedDevelopers() external view returns (address[] memory) {
        return verifiedDevelopers;
    }

    /**
     * @dev Get developer by GitHub username
     */
    function getDeveloperByGitHub(string memory githubUsername)
        external
        view
        returns (address)
    {
        return githubToAddress[githubUsername];
    }

    /**
     * @dev Get top developers by reputation
     */
    function getTopDevelopers(uint256 count) external view returns (address[] memory, uint256[] memory) {
        require(count > 0 && count <= verifiedDevelopers.length, "Invalid count");

        address[] memory topDevs = new address[](count);
        uint256[] memory topScores = new uint256[](count);

        // Simple bubble sort for top N (inefficient for large datasets but OK for demo)
        for (uint256 i = 0; i < count && i < verifiedDevelopers.length; i++) {
            address bestDev = address(0);
            uint256 bestScore = 0;

            for (uint256 j = 0; j < verifiedDevelopers.length; j++) {
                address dev = verifiedDevelopers[j];
                uint256 score = profiles[dev].reputationScore;

                // Check if this developer is already in top list
                bool alreadyIncluded = false;
                for (uint256 k = 0; k < i; k++) {
                    if (topDevs[k] == dev) {
                        alreadyIncluded = true;
                        break;
                    }
                }

                if (!alreadyIncluded && score > bestScore) {
                    bestScore = score;
                    bestDev = dev;
                }
            }

            topDevs[i] = bestDev;
            topScores[i] = bestScore;
        }

        return (topDevs, topScores);
    }

    /**
     * @dev Get reputation score as formatted string (with decimals)
     */
    function getFormattedScore(address developer) external view returns (string memory) {
        uint256 score = profiles[developer].reputationScore;
        uint256 wholePart = score / 100;
        uint256 decimalPart = score % 100;

        return string(abi.encodePacked(
            uintToString(wholePart),
            ".",
            decimalPart < 10 ? "0" : "",
            uintToString(decimalPart)
        ));
    }

    // Helper function to convert uint to string
    function uintToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }

        uint256 temp = value;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }

        return string(buffer);
    }
}
