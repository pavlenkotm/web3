package com.web3.wallet;

import org.web3j.crypto.*;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.core.methods.response.*;
import org.web3j.protocol.http.HttpService;
import org.web3j.tx.RawTransactionManager;
import org.web3j.tx.Transfer;
import org.web3j.utils.Convert;
import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.io.File;
import java.io.IOException;
import java.security.InvalidAlgorithmParameterException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.util.concurrent.Callable;

/**
 * Web3j Wallet Application
 * Ethereum wallet management and transactions
 */
@Command(name = "wallet", mixinStandardHelpOptions = true, version = "1.0.0",
        description = "Ethereum wallet CLI using Web3j")
public class WalletApp implements Callable<Integer> {

    @Option(names = {"-r", "--rpc"}, description = "RPC URL",
            defaultValue = "http://localhost:8545")
    private String rpcUrl;

    public static void main(String[] args) {
        int exitCode = new CommandLine(new WalletApp()).execute(args);
        System.exit(exitCode);
    }

    @Override
    public Integer call() {
        System.out.println("Use --help for available commands");
        return 0;
    }

    @Command(name = "create", description = "Create new wallet")
    int create(
            @Option(names = {"-p", "--password"}, required = true) String password,
            @Option(names = {"-d", "--directory"}, defaultValue = ".") String directory
    ) {
        try {
            String fileName = WalletUtils.generateNewWalletFile(
                    password, new File(directory));
            System.out.println("✓ Wallet created: " + fileName);

            Credentials credentials = WalletUtils.loadCredentials(
                    password, directory + "/" + fileName);
            System.out.println("Address: " + credentials.getAddress());

            return 0;
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            return 1;
        }
    }

    @Command(name = "balance", description = "Get ETH balance")
    int balance(@Parameters(description = "Address") String address) {
        try {
            Web3j web3j = Web3j.build(new HttpService(rpcUrl));

            EthGetBalance balanceWei = web3j.ethGetBalance(
                    address, DefaultBlockParameterName.LATEST).send();

            BigDecimal balance = Convert.fromWei(
                    balanceWei.getBalance().toString(),
                    Convert.Unit.ETHER);

            System.out.println("Balance: " + balance + " ETH");

            web3j.shutdown();
            return 0;
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            return 1;
        }
    }

    @Command(name = "send", description = "Send ETH")
    int send(
            @Option(names = {"-f", "--from"}, required = true) String walletFile,
            @Option(names = {"-p", "--password"}, required = true) String password,
            @Option(names = {"-t", "--to"}, required = true) String toAddress,
            @Option(names = {"-a", "--amount"}, required = true) String amount
    ) {
        try {
            Web3j web3j = Web3j.build(new HttpService(rpcUrl));

            Credentials credentials = WalletUtils.loadCredentials(password, walletFile);

            BigDecimal amountInEther = new BigDecimal(amount);

            System.out.println("Sending " + amountInEther + " ETH to " + toAddress + "...");

            TransactionReceipt receipt = Transfer.sendFunds(
                    web3j, credentials, toAddress,
                    amountInEther, Convert.Unit.ETHER).send();

            System.out.println("✓ Transaction successful!");
            System.out.println("Hash: " + receipt.getTransactionHash());
            System.out.println("Block: " + receipt.getBlockNumber());
            System.out.println("Gas used: " + receipt.getGasUsed());

            web3j.shutdown();
            return 0;
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            return 1;
        }
    }

    @Command(name = "info", description = "Get blockchain info")
    int info() {
        try {
            Web3j web3j = Web3j.build(new HttpService(rpcUrl));

            Web3ClientVersion clientVersion = web3j.web3ClientVersion().send();
            EthBlockNumber blockNumber = web3j.ethBlockNumber().send();
            EthGasPrice gasPrice = web3j.ethGasPrice().send();
            NetVersion netVersion = web3j.netVersion().send();

            System.out.println("=== Blockchain Info ===");
            System.out.println("Client: " + clientVersion.getWeb3ClientVersion());
            System.out.println("Network: " + netVersion.getNetVersion());
            System.out.println("Latest Block: " + blockNumber.getBlockNumber());
            System.out.println("Gas Price: " +
                    Convert.fromWei(gasPrice.getGasPrice().toString(), Convert.Unit.GWEI) + " Gwei");
            System.out.println("RPC URL: " + rpcUrl);

            web3j.shutdown();
            return 0;
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            return 1;
        }
    }

    @Command(name = "block", description = "Get block information")
    int block(@Parameters(description = "Block number") long blockNumber) {
        try {
            Web3j web3j = Web3j.build(new HttpService(rpcUrl));

            EthBlock block = web3j.ethGetBlockByNumber(
                    org.web3j.protocol.core.DefaultBlockParameter.valueOf(
                            BigInteger.valueOf(blockNumber)), true).send();

            EthBlock.Block blockData = block.getBlock();

            System.out.println("=== Block #" + blockNumber + " ===");
            System.out.println("Hash: " + blockData.getHash());
            System.out.println("Parent Hash: " + blockData.getParentHash());
            System.out.println("Miner: " + blockData.getMiner());
            System.out.println("Timestamp: " + blockData.getTimestamp());
            System.out.println("Transactions: " + blockData.getTransactions().size());
            System.out.println("Gas Used: " + blockData.getGasUsed());
            System.out.println("Gas Limit: " + blockData.getGasLimit());

            web3j.shutdown();
            return 0;
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            return 1;
        }
    }
}
