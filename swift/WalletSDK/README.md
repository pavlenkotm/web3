# Swift Ethereum Wallet SDK

Native iOS and macOS Ethereum wallet SDK built with Swift and Web3.swift.

## Features

- **Native Swift**: Pure Swift implementation
- **iOS & macOS**: Cross-platform support
- **Async/Await**: Modern Swift concurrency
- **Type Safe**: Strong typing with BigInt
- **Web3 Integration**: Full Ethereum support
- **Wallet Management**: Create and import wallets
- **Transaction Sending**: ETH transfers
- **Balance Queries**: Account balance checks

## Tech Stack

- **Swift 5.9+**: Modern Swift features
- **Web3.swift**: Ethereum library for Swift
- **BigInt**: Large number arithmetic
- **CryptoSwift**: Cryptographic operations
- **Swift Package Manager**: Dependency management

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourorg/WalletSDK.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Packages...
2. Enter repository URL
3. Add to your target

### CocoaPods

```ruby
pod 'WalletSDK', '~> 1.0'
```

### Carthage

```
github "yourorg/WalletSDK" ~> 1.0
```

## Usage

### Import Framework

```swift
import WalletSDK
```

### Create New Wallet

```swift
do {
    let wallet = try EthereumWallet(
        rpcURL: "https://mainnet.infura.io/v3/YOUR_KEY"
    )

    print("Address: \(wallet.exportAddress())")
    print("Private Key: \(wallet.exportPrivateKey())")
} catch {
    print("Error: \(error)")
}
```

### Import Existing Wallet

```swift
let privateKey = "0x1234567890abcdef..."
let wallet = try EthereumWallet(
    privateKey: privateKey,
    rpcURL: "https://mainnet.infura.io/v3/YOUR_KEY"
)
```

### Get Balance

```swift
Task {
    do {
        let balance = try await wallet.getBalanceInEth()
        print("Balance: \(balance) ETH")
    } catch {
        print("Error: \(error)")
    }
}
```

### Send ETH

```swift
Task {
    do {
        let txHash = try await wallet.sendEth(
            to: "0xRecipientAddress...",
            ethAmount: 0.1
        )
        print("Transaction: \(txHash)")
    } catch {
        print("Error: \(error)")
    }
}
```

### Advanced Transaction

```swift
Task {
    let toAddress = try EthereumAddress(
        hex: "0xRecipient...",
        eip55: true
    )

    let amount = BigUInt("1000000000000000000")! // 1 ETH in Wei
    let gasPrice = BigUInt("50000000000")! // 50 Gwei
    let gasLimit = BigUInt("21000")

    let txHash = try await wallet.sendTransaction(
        to: toAddress,
        amount: amount,
        gasPrice: gasPrice,
        gasLimit: gasLimit
    )

    print("TX Hash: \(txHash)")
}
```

## SwiftUI Integration

### Wallet View

```swift
import SwiftUI
import WalletSDK

struct WalletView: View {
    @State private var wallet: EthereumWallet?
    @State private var balance: Decimal = 0
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            if let wallet = wallet {
                Text("Address")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(wallet.exportAddress())
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                Text("\(balance.description) ETH")
                    .font(.largeTitle)
                    .bold()

                Button("Refresh Balance") {
                    Task {
                        isLoading = true
                        balance = try await wallet.getBalanceInEth()
                        isLoading = false
                    }
                }
                .disabled(isLoading)
            } else {
                Button("Create Wallet") {
                    createWallet()
                }
            }
        }
        .padding()
    }

    func createWallet() {
        Task {
            do {
                wallet = try EthereumWallet(
                    rpcURL: "https://mainnet.infura.io/v3/YOUR_KEY"
                )
                balance = try await wallet!.getBalanceInEth()
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
```

### Send Transaction View

```swift
struct SendView: View {
    let wallet: EthereumWallet

    @State private var recipient = ""
    @State private var amount = ""
    @State private var txHash: String?
    @State private var isLoading = false

    var body: some View {
        Form {
            Section("Recipient") {
                TextField("0x...", text: $recipient)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            Section("Amount (ETH)") {
                TextField("0.0", text: $amount)
                    .keyboardType(.decimalPad)
            }

            Section {
                Button("Send") {
                    sendTransaction()
                }
                .disabled(isLoading || recipient.isEmpty || amount.isEmpty)
            }

            if let txHash = txHash {
                Section("Transaction") {
                    Text(txHash)
                        .font(.caption)
                        .textSelection(.enabled)
                }
            }
        }
    }

    func sendTransaction() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let hash = try await wallet.sendEth(
                    to: recipient,
                    ethAmount: Decimal(string: amount)!
                )
                txHash = hash
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
```

## UIKit Integration

```swift
import UIKit
import WalletSDK

class WalletViewController: UIViewController {
    var wallet: EthereumWallet?

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            do {
                wallet = try EthereumWallet(
                    rpcURL: "https://mainnet.infura.io/v3/YOUR_KEY"
                )

                let balance = try await wallet!.getBalanceInEth()
                print("Balance: \(balance) ETH")
            } catch {
                print("Error: \(error)")
            }
        }
    }

    @IBAction func sendButtonTapped(_ sender: UIButton) {
        Task {
            guard let wallet = wallet else { return }

            do {
                let txHash = try await wallet.sendEth(
                    to: recipientTextField.text!,
                    ethAmount: Decimal(string: amountTextField.text!)!
                )

                showAlert(message: "Transaction sent: \(txHash)")
            } catch {
                showAlert(message: "Error: \(error.localizedDescription)")
            }
        }
    }
}
```

## Testing

```swift
import XCTest
@testable import WalletSDK

final class WalletSDKTests: XCTestCase {

    func testWalletCreation() async throws {
        let wallet = try EthereumWallet(
            rpcURL: "https://mainnet.infura.io/v3/KEY"
        )

        XCTAssertFalse(wallet.exportAddress().isEmpty)
        XCTAssertFalse(wallet.exportPrivateKey().isEmpty)
    }

    func testBalanceQuery() async throws {
        let wallet = try EthereumWallet(
            privateKey: "0x...",
            rpcURL: "https://mainnet.infura.io/v3/KEY"
        )

        let balance = try await wallet.getBalanceInEth()
        XCTAssertGreaterThanOrEqual(balance, 0)
    }
}
```

Run tests:
```bash
swift test
```

## Building

### Build Library

```bash
cd swift/WalletSDK
swift build
```

### Build for iOS

```bash
swift build -c release \
  --sdk $(xcrun --sdk iphoneos --show-sdk-path) \
  --target arm64-apple-ios
```

### Generate Xcode Project

```bash
swift package generate-xcodeproj
```

## Requirements

- iOS 15.0+ / macOS 12.0+
- Xcode 14.0+
- Swift 5.9+

## Dependencies

- [Web3.swift](https://github.com/Boilertalk/Web3.swift) - Ethereum library
- [BigInt](https://github.com/attaswift/BigInt) - Arbitrary-precision arithmetic
- [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift) - Crypto operations

## Security

- Private keys stored in memory only
- Use Keychain for persistent storage
- Never log private keys
- Validate all inputs
- Use secure RPC endpoints

## Example App

See `Examples/WalletApp` for a complete iOS app example.

## Resources

- [Swift Documentation](https://swift.org/documentation/)
- [Web3.swift Docs](https://web3swift.io/)
- [Ethereum JSON-RPC](https://ethereum.org/en/developers/docs/apis/json-rpc/)

## License

MIT
