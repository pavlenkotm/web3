/// Simple fungible token implementation on Aptos
/// Demonstrates Move's resource-oriented programming model
module token_addr::simple_token {
    use std::signer;
    use std::string::{Self, String};
    use aptos_framework::coin::{Self, Coin, MintCapability, BurnCapability};
    use aptos_framework::account;

    /// Error codes
    const E_NOT_INITIALIZED: u64 = 1;
    const E_ALREADY_INITIALIZED: u64 = 2;
    const E_INSUFFICIENT_BALANCE: u64 = 3;
    const E_NOT_OWNER: u64 = 4;

    /// Token capabilities stored under module owner
    struct Capabilities<phantom CoinType> has key {
        mint_cap: MintCapability<CoinType>,
        burn_cap: BurnCapability<CoinType>,
    }

    /// Token metadata
    struct TokenInfo has key {
        name: String,
        symbol: String,
        decimals: u8,
        owner: address,
    }

    /// Initialize the token with given parameters
    public entry fun initialize(
        account: &signer,
        name: vector<u8>,
        symbol: vector<u8>,
        decimals: u8,
        monitor_supply: bool,
    ) {
        let account_addr = signer::address_of(account);

        // Ensure not already initialized
        assert!(!exists<TokenInfo>(account_addr), E_ALREADY_INITIALIZED);

        // Initialize coin
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<SimpleToken>(
            account,
            string::utf8(name),
            string::utf8(symbol),
            decimals,
            monitor_supply,
        );

        // Store capabilities
        move_to(account, Capabilities<SimpleToken> {
            mint_cap,
            burn_cap,
        });

        // Destroy freeze capability (not using it)
        coin::destroy_freeze_cap(freeze_cap);

        // Store token info
        move_to(account, TokenInfo {
            name: string::utf8(name),
            symbol: string::utf8(symbol),
            decimals,
            owner: account_addr,
        });
    }

    /// Mint new tokens to recipient
    public entry fun mint(
        owner: &signer,
        recipient: address,
        amount: u64,
    ) acquires Capabilities {
        let owner_addr = signer::address_of(owner);

        // Verify owner
        assert!(exists<TokenInfo>(owner_addr), E_NOT_INITIALIZED);
        let token_info = borrow_global<TokenInfo>(owner_addr);
        assert!(token_info.owner == owner_addr, E_NOT_OWNER);

        // Mint tokens
        let caps = borrow_global<Capabilities<SimpleToken>>(owner_addr);
        let coins = coin::mint<SimpleToken>(amount, &caps.mint_cap);

        // Register recipient if needed
        if (!coin::is_account_registered<SimpleToken>(recipient)) {
            coin::register<SimpleToken>(owner);
        };

        // Deposit tokens
        coin::deposit<SimpleToken>(recipient, coins);
    }

    /// Transfer tokens to another account
    public entry fun transfer(
        from: &signer,
        to: address,
        amount: u64,
    ) {
        // Register recipient if needed
        if (!coin::is_account_registered<SimpleToken>(to)) {
            let from_addr = signer::address_of(from);
            assert!(exists<TokenInfo>(from_addr), E_NOT_INITIALIZED);
            coin::register<SimpleToken>(from);
        };

        // Transfer
        coin::transfer<SimpleToken>(from, to, amount);
    }

    /// Burn tokens from sender's account
    public entry fun burn(
        account: &signer,
        amount: u64,
    ) acquires Capabilities {
        let account_addr = signer::address_of(account);

        // Get capabilities
        assert!(exists<Capabilities<SimpleToken>>(account_addr), E_NOT_INITIALIZED);
        let caps = borrow_global<Capabilities<SimpleToken>>(account_addr);

        // Withdraw and burn
        let coins = coin::withdraw<SimpleToken>(account, amount);
        coin::burn<SimpleToken>(coins, &caps.burn_cap);
    }

    /// Get token balance
    public fun balance(account: address): u64 {
        coin::balance<SimpleToken>(account)
    }

    /// Get token name
    public fun name(): String acquires TokenInfo {
        let token_info = borrow_global<TokenInfo>(@token_addr);
        token_info.name
    }

    /// Get token symbol
    public fun symbol(): String acquires TokenInfo {
        let token_info = borrow_global<TokenInfo>(@token_addr);
        token_info.symbol
    }

    /// Get token decimals
    public fun decimals(): u8 acquires TokenInfo {
        let token_info = borrow_global<TokenInfo>(@token_addr);
        token_info.decimals
    }

    /// Token coin type marker
    struct SimpleToken {}

    #[test(owner = @0x1)]
    public fun test_initialize(owner: &signer) {
        initialize(
            owner,
            b"Test Token",
            b"TEST",
            8,
            true
        );

        assert!(exists<TokenInfo>(signer::address_of(owner)), 0);
    }

    #[test(owner = @0x1)]
    public fun test_mint_and_transfer(owner: &signer) acquires Capabilities {
        // Initialize
        initialize(owner, b"Test", b"TST", 8, true);

        // Mint
        let owner_addr = signer::address_of(owner);
        mint(owner, owner_addr, 1000);

        // Check balance
        assert!(balance(owner_addr) == 1000, 0);
    }
}
