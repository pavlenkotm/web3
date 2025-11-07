# Kotlin Android Wallet

Native Android Ethereum wallet application built with Kotlin, Jetpack Compose, and Web3j.

## Features

- **Native Android**: Built with modern Android development practices
- **Jetpack Compose**: Modern declarative UI
- **Web3j Integration**: Full Ethereum support
- **Secure Storage**: Encrypted wallet storage with AndroidKeyStore
- **Coroutines**: Asynchronous operations with Kotlin Coroutines
- **Material 3**: Latest Material Design components
- **MVVM Architecture**: Clean architecture pattern

## Tech Stack

- **Kotlin**: Primary programming language
- **Jetpack Compose**: UI framework
- **Web3j**: Ethereum library for Android
- **Coroutines**: Async/await pattern
- **ViewModel**: State management
- **AndroidKeyStore**: Secure key storage

## Prerequisites

- Android Studio Hedgehog or later
- Android SDK 24+ (Android 7.0+)
- Kotlin 1.9+

## Setup

### Clone and Open

```bash
cd kotlin/android-wallet
```

Open in Android Studio.

### Configure RPC

Edit `WalletManager.kt`:

```kotlin
class WalletManager(
    private val context: Context,
    rpcUrl: String = "https://mainnet.infura.io/v3/YOUR_KEY"
)
```

### Build

```bash
./gradlew build
```

### Run

```bash
./gradlew installDebug
```

Or click ▶️ in Android Studio.

## Usage

### Initialize Wallet Manager

```kotlin
val walletManager = WalletManager(
    context = applicationContext,
    rpcUrl = "https://mainnet.infura.io/v3/YOUR_KEY"
)
```

### Create New Wallet

```kotlin
lifecycleScope.launch {
    try {
        val address = walletManager.createWallet("password123")
        println("Created wallet: $address")
    } catch (e: Exception) {
        e.printStackTrace()
    }
}
```

### Load Existing Wallet

```kotlin
lifecycleScope.launch {
    val address = walletManager.loadWallet(
        password = "password123",
        fileName = "UTC--2024-01-15..."
    )
    println("Loaded: $address")
}
```

### Get Balance

```kotlin
lifecycleScope.launch {
    val balance = walletManager.getBalance()
    println("Balance: $balance ETH")
}
```

### Send Transaction

```kotlin
lifecycleScope.launch {
    try {
        val txHash = walletManager.sendTransaction(
            toAddress = "0xRecipient...",
            amount = BigDecimal("0.1")
        )
        println("Transaction: $txHash")
    } catch (e: Exception) {
        e.printStackTrace()
    }
}
```

## Jetpack Compose UI

### Main Screen

```kotlin
@Composable
fun WalletScreen(
    walletManager: WalletManager,
    viewModel: WalletViewModel = viewModel()
) {
    val address by viewModel.address.collectAsState()
    val balance by viewModel.balance.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text(
            text = "My Wallet",
            style = MaterialTheme.typography.headlineMedium
        )

        Spacer(modifier = Modifier.height(16.dp))

        Card(
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text("Address")
                Text(
                    text = WalletManager.formatAddress(address),
                    style = MaterialTheme.typography.bodyMedium
                )

                Spacer(modifier = Modifier.height(8.dp))

                Text("Balance")
                Text(
                    text = "$balance ETH",
                    style = MaterialTheme.typography.headlineSmall
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        Button(
            onClick = { /* Refresh balance */ },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Refresh Balance")
        }
    }
}
```

### Send Transaction Screen

```kotlin
@Composable
fun SendScreen(walletManager: WalletManager) {
    var toAddress by remember { mutableStateOf("") }
    var amount by remember { mutableStateOf("") }
    var isLoading by remember { mutableStateOf(false) }

    val scope = rememberCoroutineScope()

    Column(modifier = Modifier.padding(16.dp)) {
        OutlinedTextField(
            value = toAddress,
            onValueChange = { toAddress = it },
            label = { Text("Recipient Address") },
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(8.dp))

        OutlinedTextField(
            value = amount,
            onValueChange = { amount = it },
            label = { Text("Amount (ETH)") },
            keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.Decimal
            ),
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(16.dp))

        Button(
            onClick = {
                scope.launch {
                    isLoading = true
                    try {
                        val txHash = walletManager.sendTransaction(
                            toAddress,
                            BigDecimal(amount)
                        )
                        // Show success
                    } catch (e: Exception) {
                        // Show error
                    } finally {
                        isLoading = false
                    }
                }
            },
            enabled = !isLoading && toAddress.isNotEmpty() && amount.isNotEmpty(),
            modifier = Modifier.fillMaxWidth()
        ) {
            if (isLoading) {
                CircularProgressIndicator(
                    modifier = Modifier.size(20.dp),
                    color = MaterialTheme.colorScheme.onPrimary
                )
            } else {
                Text("Send")
            }
        }
    }
}
```

## Architecture

### MVVM Pattern

```
app/
├── data/
│   ├── repository/
│   │   └── WalletRepository.kt
│   └── model/
│       └── Transaction.kt
├── domain/
│   └── usecase/
│       ├── SendTransactionUseCase.kt
│       └── GetBalanceUseCase.kt
├── ui/
│   ├── wallet/
│   │   ├── WalletScreen.kt
│   │   └── WalletViewModel.kt
│   └── send/
│       ├── SendScreen.kt
│       └── SendViewModel.kt
└── WalletManager.kt
```

### ViewModel Example

```kotlin
class WalletViewModel(
    private val walletManager: WalletManager
) : ViewModel() {

    private val _balance = MutableStateFlow(BigDecimal.ZERO)
    val balance: StateFlow<BigDecimal> = _balance.asStateFlow()

    private val _address = MutableStateFlow("")
    val address: StateFlow<String> = _address.asStateFlow()

    fun refreshBalance() {
        viewModelScope.launch {
            try {
                _balance.value = walletManager.getBalance()
            } catch (e: Exception) {
                // Handle error
            }
        }
    }

    fun sendTransaction(to: String, amount: BigDecimal) {
        viewModelScope.launch {
            try {
                val txHash = walletManager.sendTransaction(to, amount)
                // Handle success
            } catch (e: Exception) {
                // Handle error
            }
        }
    }
}
```

## Secure Storage

### AndroidKeyStore

```kotlin
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKeys

val masterKeyAlias = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC)

val sharedPreferences = EncryptedSharedPreferences.create(
    "secure_prefs",
    masterKeyAlias,
    context,
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)

// Save wallet file name
sharedPreferences.edit().putString("wallet_file", fileName).apply()
```

## Testing

### Unit Tests

```kotlin
@Test
fun `test wallet creation`() = runTest {
    val walletManager = WalletManager(context, testRpcUrl)
    val address = walletManager.createWallet("password")

    assertTrue(WalletManager.isValidAddress(address))
}
```

### Instrumented Tests

```kotlin
@Test
fun testWalletActivity() {
    val scenario = launchActivity<WalletActivity>()

    onView(withId(R.id.createWalletButton))
        .perform(click())

    onView(withId(R.id.addressText))
        .check(matches(isDisplayed()))
}
```

Run tests:
```bash
./gradlew test
./gradlew connectedAndroidTest
```

## Dependencies

```kotlin
// Core
implementation("org.web3j:core:4.10.3")

// Jetpack Compose
implementation("androidx.compose.material3:material3")

// Coroutines
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")

// Security
implementation("androidx.security:security-crypto:1.1.0-alpha06")
```

## Permissions

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET" />
</manifest>
```

## ProGuard Rules

```proguard
# Web3j
-keep class org.web3j.** { *; }
-dontwarn org.web3j.**

# Bouncy Castle
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**
```

## Resources

- [Android Developers](https://developer.android.com/)
- [Jetpack Compose](https://developer.android.com/jetpack/compose)
- [Web3j Android](https://docs.web3j.io/4.10.0/android/)
- [Kotlin Coroutines](https://kotlinlang.org/docs/coroutines-overview.html)

## License

MIT
