# Java Web3j Wallet

Enterprise-grade Ethereum wallet application built with Java and Web3j library.

## Features

- **Wallet Management**: Create and manage Ethereum wallets
- **ETH Transactions**: Send and receive ETH
- **Balance Queries**: Check account balances
- **Blockchain Info**: Query network and block data
- **CLI Interface**: Professional command-line tool
- **Production Ready**: Enterprise Java standards

## Tech Stack

- **Java 17**: Modern Java LTS version
- **Web3j 4.10**: Official Ethereum Java library
- **Maven**: Dependency management
- **Picocli**: CLI framework
- **JUnit 5**: Testing framework

## Prerequisites

- Java 17 or higher
- Maven 3.8+

## Installation

### Build Project

```bash
cd java/web3j-wallet

# Compile
mvn clean compile

# Package JAR
mvn package

# Run tests
mvn test
```

### Run Application

```bash
# Using Maven
mvn exec:java -Dexec.mainClass="com.web3.wallet.WalletApp"

# Using JAR
java -jar target/web3j-wallet-1.0.0.jar
```

## Usage

### Create New Wallet

```bash
java -jar target/web3j-wallet-1.0.0.jar create \
  --password yourSecurePassword \
  --directory ./wallets

# Output:
# ✓ Wallet created: UTC--2024-01-15T10-30-45.123456789Z--abc123...
# Address: 0xabc123...
```

### Check Balance

```bash
java -jar target/web3j-wallet-1.0.0.jar balance 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb

# Output:
# Balance: 1.234567 ETH
```

### Send ETH

```bash
java -jar target/web3j-wallet-1.0.0.jar send \
  --from ./wallets/UTC--2024... \
  --password yourPassword \
  --to 0xRecipient... \
  --amount 0.1

# Output:
# Sending 0.1 ETH to 0xRecipient...
# ✓ Transaction successful!
# Hash: 0x123...
# Block: 18000000
# Gas used: 21000
```

### Get Blockchain Info

```bash
java -jar target/web3j-wallet-1.0.0.jar info --rpc https://mainnet.infura.io/v3/KEY

# Output:
# === Blockchain Info ===
# Client: Geth/v1.13.0
# Network: 1
# Latest Block: 19000000
# Gas Price: 25.5 Gwei
# RPC URL: https://mainnet.infura.io/v3/KEY
```

### Get Block Info

```bash
java -jar target/web3j-wallet-1.0.0.jar block 18000000

# Output:
# === Block #18000000 ===
# Hash: 0x...
# Parent Hash: 0x...
# Miner: 0x...
# Timestamp: 1695648023
# Transactions: 150
# Gas Used: 15000000
# Gas Limit: 30000000
```

## Java Library Usage

### Initialize Web3j

```java
import org.web3j.protocol.Web3j;
import org.web3j.protocol.http.HttpService;

Web3j web3j = Web3j.build(new HttpService("https://mainnet.infura.io/v3/YOUR_KEY"));
```

### Load Wallet

```java
import org.web3j.crypto.Credentials;
import org.web3j.crypto.WalletUtils;

Credentials credentials = WalletUtils.loadCredentials(
    "password",
    "/path/to/walletfile"
);

String address = credentials.getAddress();
```

### Send Transaction

```java
import org.web3j.tx.Transfer;
import org.web3j.utils.Convert;
import java.math.BigDecimal;

TransactionReceipt receipt = Transfer.sendFunds(
    web3j,
    credentials,
    "0xRecipientAddress",
    new BigDecimal("0.1"),
    Convert.Unit.ETHER
).send();

System.out.println("TX Hash: " + receipt.getTransactionHash());
```

### Call Smart Contract

```java
import org.web3j.tx.gas.DefaultGasProvider;

// Load contract (generated with web3j CLI)
YourContract contract = YourContract.load(
    contractAddress,
    web3j,
    credentials,
    new DefaultGasProvider()
);

// Call view function
BigInteger balance = contract.balanceOf(address).send();

// Send transaction
TransactionReceipt receipt = contract.transfer(
    recipientAddress,
    BigInteger.valueOf(1000)
).send();
```

### Generate Contract Wrappers

```bash
# Install web3j CLI
curl -L https://get.web3j.io | sh

# Generate Java wrapper from ABI
web3j generate solidity \
  -a contract.abi \
  -b contract.bin \
  -o src/main/java \
  -p com.web3.contracts
```

## Project Structure

```
java/web3j-wallet/
├── src/
│   ├── main/
│   │   └── java/
│   │       └── com/
│   │           └── web3/
│   │               └── wallet/
│   │                   └── WalletApp.java
│   └── test/
│       └── java/
│           └── com/
│               └── web3/
│                   └── wallet/
│                       └── WalletAppTest.java
├── pom.xml
└── README.md
```

## Advanced Features

### Subscribe to Events

```java
import org.web3j.protocol.core.methods.request.EthFilter;

EthFilter filter = new EthFilter(
    DefaultBlockParameterName.LATEST,
    DefaultBlockParameterName.LATEST,
    contractAddress
);

web3j.ethLogFlowable(filter).subscribe(log -> {
    System.out.println("New event: " + log);
});
```

### Batch Requests

```java
import org.web3j.protocol.core.BatchRequest;
import org.web3j.protocol.core.BatchResponse;

BatchRequest batch = web3j.newBatch();
batch.add(web3j.ethBlockNumber());
batch.add(web3j.ethGasPrice());

BatchResponse response = batch.send();
```

### Custom Transaction

```java
import org.web3j.tx.RawTransactionManager;
import org.web3j.crypto.RawTransaction;

BigInteger nonce = web3j.ethGetTransactionCount(
    address, DefaultBlockParameterName.LATEST
).send().getTransactionCount();

RawTransaction rawTx = RawTransaction.createEtherTransaction(
    nonce,
    gasPrice,
    gasLimit,
    toAddress,
    value
);

byte[] signedMessage = TransactionEncoder.signMessage(rawTx, credentials);
String hexValue = Numeric.toHexString(signedMessage);

EthSendTransaction response = web3j.ethSendRawTransaction(hexValue).send();
```

## Testing

### Unit Tests

```java
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

@Test
void testWalletCreation() {
    // Test implementation
}

@Test
void testBalanceQuery() {
    // Test implementation
}
```

Run tests:
```bash
mvn test
```

## Dependencies

```xml
<dependency>
    <groupId>org.web3j</groupId>
    <artifactId>core</artifactId>
    <version>4.10.3</version>
</dependency>
```

## Performance

- **Startup Time**: ~2-3 seconds
- **Memory Usage**: ~50-100 MB
- **Transaction Speed**: Network dependent
- **Thread Safe**: Yes

## Common Issues

### Connection Timeout

```java
HttpService httpService = new HttpService(rpcUrl);
httpService.setReadTimeout(60000); // 60 seconds
Web3j web3j = Web3j.build(httpService);
```

### Gas Price Estimation

```java
BigInteger gasPrice = web3j.ethGasPrice().send().getGasPrice();
BigInteger adjustedPrice = gasPrice.multiply(BigInteger.valueOf(12)).divide(BigInteger.valueOf(10)); // +20%
```

## Resources

- [Web3j Documentation](https://docs.web3j.io/)
- [Java Documentation](https://docs.oracle.com/en/java/)
- [Maven Guide](https://maven.apache.org/guides/)
- [Picocli](https://picocli.info/)

## License

MIT
