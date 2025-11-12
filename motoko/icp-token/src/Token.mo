import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Result "mo:base/Result";

actor Token {
    // Type definitions
    public type TxIndex = Nat;
    public type Account = Principal;
    public type Tokens = Nat;

    public type TransferError = {
        #InsufficientBalance;
        #InsufficientAllowance;
    };

    public type TransferResult = Result.Result<TxIndex, TransferError>;

    // Token metadata
    private stable let name_ : Text = "Simple Token";
    private stable let symbol_ : Text = "SMPL";
    private stable let decimals_ : Nat8 = 8;

    // Storage
    private stable var totalSupply_ : Tokens = 0;
    private stable var txCounter : TxIndex = 0;

    private var balances = HashMap.HashMap<Account, Tokens>(
        10,
        Principal.equal,
        Principal.hash
    );

    private var allowances = HashMap.HashMap<Account, HashMap.HashMap<Account, Tokens>>(
        10,
        Principal.equal,
        Principal.hash
    );

    // Upgrade hooks
    private stable var balancesEntries : [(Account, Tokens)] = [];

    system func preupgrade() {
        balancesEntries := Iter.toArray(balances.entries());
    };

    system func postupgrade() {
        balances := HashMap.fromIter<Account, Tokens>(
            balancesEntries.vals(),
            10,
            Principal.equal,
            Principal.hash
        );
        balancesEntries := [];
    };

    // Query functions
    public query func name() : async Text {
        name_
    };

    public query func symbol() : async Text {
        symbol_
    };

    public query func decimals() : async Nat8 {
        decimals_
    };

    public query func totalSupply() : async Tokens {
        totalSupply_
    };

    public query func balanceOf(account : Account) : async Tokens {
        _balanceOf(account)
    };

    public query func allowance(owner : Account, spender : Account) : async Tokens {
        _allowance(owner, spender)
    };

    // Update functions
    public shared(msg) func transfer(to : Account, value : Tokens) : async TransferResult {
        await _transfer(msg.caller, to, value)
    };

    public shared(msg) func transferFrom(
        from : Account,
        to : Account,
        value : Tokens
    ) : async TransferResult {
        let allowance = _allowance(from, msg.caller);

        if (allowance < value) {
            return #err(#InsufficientAllowance);
        };

        _updateAllowance(from, msg.caller, allowance - value);
        await _transfer(from, to, value)
    };

    public shared(msg) func approve(spender : Account, value : Tokens) : async Bool {
        _updateAllowance(msg.caller, spender, value);
        true
    };

    // Mint function (for demonstration - in production, restrict access)
    public shared(msg) func mint(to : Account, value : Tokens) : async Bool {
        _mint(to, value);
        true
    };

    // Private helper functions
    private func _balanceOf(account : Account) : Tokens {
        Option.get(balances.get(account), 0)
    };

    private func _allowance(owner : Account, spender : Account) : Tokens {
        switch (allowances.get(owner)) {
            case (?ownerAllowances) {
                Option.get(ownerAllowances.get(spender), 0)
            };
            case (null) { 0 };
        }
    };

    private func _transfer(from : Account, to : Account, value : Tokens) : async TransferResult {
        let fromBalance = _balanceOf(from);

        if (fromBalance < value) {
            return #err(#InsufficientBalance);
        };

        let toBalance = _balanceOf(to);

        balances.put(from, fromBalance - value);
        balances.put(to, toBalance + value);

        txCounter += 1;
        #ok(txCounter)
    };

    private func _mint(to : Account, value : Tokens) {
        let toBalance = _balanceOf(to);
        balances.put(to, toBalance + value);
        totalSupply_ += value;
        txCounter += 1;
    };

    private func _updateAllowance(owner : Account, spender : Account, value : Tokens) {
        switch (allowances.get(owner)) {
            case (?ownerAllowances) {
                ownerAllowances.put(spender, value);
            };
            case (null) {
                let newAllowances = HashMap.HashMap<Account, Tokens>(
                    10,
                    Principal.equal,
                    Principal.hash
                );
                newAllowances.put(spender, value);
                allowances.put(owner, newAllowances);
            };
        }
    };
}
