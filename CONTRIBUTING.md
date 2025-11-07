# Contributing to Web3 Multi-Language Repository

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## 🤝 Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## 🚀 Getting Started

### Prerequisites

- Git
- Node.js 18+
- Python 3.9+
- Rust (for Solana projects)
- Go 1.21+ (for Go projects)
- Java 17+ (for Java projects)

### Setup Development Environment

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/web3.git
cd web3

# Install dependencies
npm install

# Create a branch
git checkout -b feature/your-feature-name
```

## 📝 How to Contribute

### Reporting Bugs

1. Check existing issues
2. Use the bug report template
3. Include:
   - Description
   - Steps to reproduce
   - Expected behavior
   - Screenshots (if applicable)
   - Environment details

### Suggesting Enhancements

1. Check existing feature requests
2. Explain the use case
3. Provide examples
4. Consider implementation details

### Pull Requests

1. **Create an Issue First**: Discuss major changes before implementing
2. **Follow Coding Standards**: Match the style of existing code
3. **Write Tests**: Add tests for new functionality
4. **Update Documentation**: Keep README and docs up-to-date
5. **Commit Convention**: Follow Conventional Commits

## 💻 Development Guidelines

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add ERC-1155 multi-token contract
fix: resolve gas estimation bug
docs: update Python CLI documentation
test: add integration tests for DEX
chore: update dependencies
ci: add Rust build to GitHub Actions
refactor: optimize matching engine performance
style: format Solidity contracts
```

### Code Style

#### Solidity
```solidity
// Use latest Solidity version
pragma solidity ^0.8.20;

// Follow official style guide
// Use meaningful variable names
// Add NatSpec comments
```

#### Python
```python
# Use Black formatter
# Follow PEP 8
# Type hints for functions
def get_balance(address: str) -> Decimal:
    """Get ETH balance for address."""
    pass
```

#### TypeScript
```typescript
// Use ESLint + Prettier
// Proper type annotations
interface WalletConfig {
  rpcUrl: string;
  chainId: number;
}
```

#### Rust
```rust
// Use rustfmt
// Follow Rust API guidelines
pub fn mint_token(amount: u64) -> Result<()> {
    // Implementation
}
```

### Testing Requirements

- **Smart Contracts**: Hardhat tests with >80% coverage
- **Python**: pytest with type checking
- **TypeScript**: Jest or Vitest
- **Rust**: cargo test
- **Go**: go test

```bash
# Run tests before committing
npm test
cd python/web3-cli && pytest
cd rust/solana-token-program && cargo test
```

### Documentation

- Every new feature needs documentation
- Update relevant README.md files
- Add code comments for complex logic
- Include usage examples

## 🏗️ Project Structure

```
web3/
├── contracts/          # Solidity/Vyper contracts
├── rust/              # Rust programs
├── python/            # Python applications
├── typescript/        # TypeScript projects
├── java/              # Java applications
├── kotlin/            # Kotlin Android apps
├── swift/             # Swift iOS SDKs
├── go/                # Go utilities
├── c/                 # C libraries
├── cpp/               # C++ applications
├── bash/              # Shell scripts
└── html-css/          # Frontend projects
```

## 🔍 Code Review Process

1. **Automated Checks**: CI must pass
2. **Manual Review**: At least one approving review
3. **Testing**: All tests must pass
4. **Documentation**: Docs must be updated
5. **No Conflicts**: Resolve merge conflicts

## 🎯 Areas for Contribution

### High Priority

- Additional language examples
- More comprehensive tests
- Performance optimizations
- Security improvements
- Documentation enhancements

### Good First Issues

Look for issues labeled `good-first-issue` or `help-wanted`.

### Language-Specific

- **Solidity**: Add ERC standards (ERC-1155, ERC-4626)
- **Rust**: Add more Solana programs
- **Python**: Expand CLI functionality
- **TypeScript**: Add more DApp features
- **Mobile**: Enhance iOS/Android wallets

## 🚫 What NOT to Contribute

- Unrelated code or features
- Breaking changes without discussion
- Code without tests
- Poorly documented changes
- Malicious code
- Private keys or sensitive data

## 📦 Adding a New Language

To add a new programming language to the repository:

1. Create a new directory: `language-name/`
2. Add a comprehensive README.md
3. Include working code examples
4. Add tests
5. Update root README.md
6. Add CI/CD integration
7. Submit PR with clear description

### Template Structure

```
new-language/
├── README.md          # Comprehensive documentation
├── src/               # Source code
├── tests/             # Test files
├── examples/          # Usage examples
└── package.*          # Dependency management
```

## 🔐 Security

- **DO NOT** commit private keys, secrets, or credentials
- Use `.env` files for sensitive data
- Report security vulnerabilities privately
- Follow security best practices
- Add security tests

## 🏆 Recognition

Contributors will be recognized in:
- GitHub contributors list
- Project documentation
- Release notes

## 📞 Need Help?

- Join [GitHub Discussions](https://github.com/pavlenkotm/web3/discussions)
- Open an issue with the `question` label
- Review existing documentation

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to the Web3 Multi-Language Repository! 🎉
