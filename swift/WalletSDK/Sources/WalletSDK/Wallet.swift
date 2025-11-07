import Foundation
import Web3
import BigInt
import CryptoSwift

/// Ethereum wallet for iOS/macOS
public class EthereumWallet {

    /// Wallet address
    public let address: EthereumAddress

    /// Private key
    private let privateKey: EthereumPrivateKey

    /// Web3 provider
    private let web3: Web3

    /// Initialize with private key
    /// - Parameters:
    ///   - privateKey: Private key hex string
    ///   - rpcURL: Ethereum RPC endpoint
    public init(privateKey: String, rpcURL: String) throws {
        self.privateKey = try EthereumPrivateKey(hexPrivateKey: privateKey)
        self.address = try EthereumAddress(hex: self.privateKey.address.hex(eip55: true), eip55: true)
        self.web3 = Web3(rpcURL: rpcURL)
    }

    /// Generate new random wallet
    /// - Parameter rpcURL: Ethereum RPC endpoint
    public init(rpcURL: String) throws {
        self.privateKey = try EthereumPrivateKey()
        self.address = try EthereumAddress(hex: self.privateKey.address.hex(eip55: true), eip55: true)
        self.web3 = Web3(rpcURL: rpcURL)
    }

    /// Get ETH balance
    /// - Returns: Balance in Wei
    public func getBalance() async throws -> BigUInt {
        return try await withCheckedThrowingContinuation { continuation in
            web3.eth.getBalance(address: address, block: .latest) { response in
                switch response.status {
                case .success(let balance):
                    continuation.resume(returning: balance.quantity)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Get balance in ETH
    /// - Returns: Balance in ETH as Decimal
    public func getBalanceInEth() async throws -> Decimal {
        let balanceWei = try await getBalance()
        return Decimal(string: balanceWei.description)! / Decimal(string: "1000000000000000000")!
    }

    /// Send ETH transaction
    /// - Parameters:
    ///   - to: Recipient address
    ///   - amount: Amount in Wei
    ///   - gasPrice: Gas price (optional)
    ///   - gasLimit: Gas limit (optional)
    /// - Returns: Transaction hash
    public func sendTransaction(
        to: EthereumAddress,
        amount: BigUInt,
        gasPrice: BigUInt? = nil,
        gasLimit: BigUInt? = nil
    ) async throws -> String {

        // Get nonce
        let nonce = try await getNonce()

        // Get gas price if not provided
        let txGasPrice = gasPrice ?? (try await getGasPrice())

        // Build transaction
        let transaction = EthereumTransaction(
            from: address,
            to: to,
            value: amount,
            data: Data(),
            nonce: nonce,
            gasPrice: txGasPrice,
            gasLimit: gasLimit ?? 21000,
            chainId: try await getChainId()
        )

        // Sign transaction
        let signedTx = try transaction.sign(with: privateKey)

        // Send transaction
        return try await withCheckedThrowingContinuation { continuation in
            web3.eth.sendRawTransaction(transaction: signedTx) { response in
                switch response.status {
                case .success(let hash):
                    continuation.resume(returning: hash)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Send ETH with amount in ETH
    /// - Parameters:
    ///   - to: Recipient address string
    ///   - ethAmount: Amount in ETH
    /// - Returns: Transaction hash
    public func sendEth(to: String, ethAmount: Decimal) async throws -> String {
        let toAddress = try EthereumAddress(hex: to, eip55: true)
        let weiAmount = BigUInt((ethAmount * Decimal(string: "1000000000000000000")!).description)!
        return try await sendTransaction(to: toAddress, amount: weiAmount)
    }

    /// Get transaction nonce
    /// - Returns: Nonce value
    private func getNonce() async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            web3.eth.getTransactionCount(address: address, block: .latest) { response in
                switch response.status {
                case .success(let count):
                    continuation.resume(returning: count)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Get current gas price
    /// - Returns: Gas price in Wei
    private func getGasPrice() async throws -> BigUInt {
        return try await withCheckedThrowingContinuation { continuation in
            web3.eth.gasPrice { response in
                switch response.status {
                case .success(let price):
                    continuation.resume(returning: price.quantity)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Get chain ID
    /// - Returns: Chain ID
    private func getChainId() async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            web3.eth.chainId { response in
                switch response.status {
                case .success(let chainId):
                    continuation.resume(returning: chainId)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Export private key (hex)
    /// - Returns: Private key hex string
    public func exportPrivateKey() -> String {
        return privateKey.rawPrivateKey.toHexString()
    }

    /// Export address
    /// - Returns: Checksummed address
    public func exportAddress() -> String {
        return address.hex(eip55: true)
    }
}

// MARK: - Extensions

extension Data {
    func toHexString() -> String {
        return "0x" + self.map { String(format: "%02x", $0) }.joined()
    }
}
