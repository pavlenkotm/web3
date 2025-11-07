package com.web3.wallet

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.web3j.crypto.Credentials
import org.web3j.crypto.WalletUtils
import org.web3j.protocol.Web3j
import org.web3j.protocol.core.DefaultBlockParameterName
import org.web3j.protocol.http.HttpService
import org.web3j.tx.Transfer
import org.web3j.utils.Convert
import java.io.File
import java.math.BigDecimal
import java.math.BigInteger

/**
 * Ethereum Wallet Manager for Android
 * Handles wallet creation, loading, and transactions
 */
class WalletManager(
    private val context: Context,
    rpcUrl: String = "https://mainnet.infura.io/v3/YOUR_KEY"
) {

    private val web3j: Web3j = Web3j.build(HttpService(rpcUrl))
    private var credentials: Credentials? = null

    /**
     * Create new wallet
     * @param password Wallet encryption password
     * @return Wallet address
     */
    suspend fun createWallet(password: String): String = withContext(Dispatchers.IO) {
        val walletDir = context.filesDir
        val fileName = WalletUtils.generateNewWalletFile(password, walletDir)

        credentials = WalletUtils.loadCredentials(password, File(walletDir, fileName))

        credentials!!.address
    }

    /**
     * Load existing wallet
     * @param password Wallet password
     * @param fileName Wallet file name
     */
    suspend fun loadWallet(password: String, fileName: String): String =
        withContext(Dispatchers.IO) {
            val walletFile = File(context.filesDir, fileName)
            credentials = WalletUtils.loadCredentials(password, walletFile)

            credentials!!.address
        }

    /**
     * Get ETH balance
     * @param address Ethereum address
     * @return Balance in ETH
     */
    suspend fun getBalance(address: String? = null): BigDecimal =
        withContext(Dispatchers.IO) {
            val targetAddress = address ?: credentials?.address
                ?: throw IllegalStateException("No address provided and no wallet loaded")

            val balance = web3j.ethGetBalance(
                targetAddress,
                DefaultBlockParameterName.LATEST
            ).send()

            Convert.fromWei(balance.balance.toString(), Convert.Unit.ETHER)
        }

    /**
     * Send ETH transaction
     * @param toAddress Recipient address
     * @param amount Amount in ETH
     * @return Transaction hash
     */
    suspend fun sendTransaction(
        toAddress: String,
        amount: BigDecimal
    ): String = withContext(Dispatchers.IO) {
        val creds = credentials
            ?: throw IllegalStateException("No wallet loaded")

        val receipt = Transfer.sendFunds(
            web3j,
            creds,
            toAddress,
            amount,
            Convert.Unit.ETHER
        ).send()

        receipt.transactionHash
    }

    /**
     * Get current gas price
     * @return Gas price in Gwei
     */
    suspend fun getGasPrice(): BigDecimal = withContext(Dispatchers.IO) {
        val gasPrice = web3j.ethGasPrice().send()
        Convert.fromWei(gasPrice.gasPrice.toString(), Convert.Unit.GWEI)
    }

    /**
     * Get latest block number
     * @return Block number
     */
    suspend fun getBlockNumber(): BigInteger = withContext(Dispatchers.IO) {
        web3j.ethBlockNumber().send().blockNumber
    }

    /**
     * Get wallet address
     */
    fun getAddress(): String? = credentials?.address

    /**
     * Export private key (use with caution!)
     */
    fun exportPrivateKey(): String? = credentials?.ecKeyPair?.privateKey?.toString(16)

    /**
     * Check if wallet is loaded
     */
    fun isWalletLoaded(): Boolean = credentials != null

    /**
     * Clear wallet from memory
     */
    fun clearWallet() {
        credentials = null
    }

    /**
     * Shutdown Web3j connection
     */
    fun shutdown() {
        web3j.shutdown()
    }

    companion object {
        /**
         * Validate Ethereum address
         */
        fun isValidAddress(address: String): Boolean {
            return address.matches(Regex("^0x[a-fA-F0-9]{40}$"))
        }

        /**
         * Format address for display
         */
        fun formatAddress(address: String): String {
            return "${address.substring(0, 6)}...${address.substring(address.length - 4)}"
        }
    }
}
