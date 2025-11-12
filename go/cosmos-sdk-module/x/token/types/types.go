package types

import (
	"fmt"

	sdk "github.com/cosmos/cosmos-sdk/types"
	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"
)

const (
	// ModuleName defines the module name
	ModuleName = "token"

	// StoreKey defines the primary module store key
	StoreKey = ModuleName

	// RouterKey defines the module's message routing key
	RouterKey = ModuleName

	// QuerierRoute defines the module's query routing key
	QuerierRoute = ModuleName

	// MemStoreKey defines the in-memory store key
	MemStoreKey = "mem_token"
)

var (
	// BalanceKeyPrefix is the prefix for balance keys
	BalanceKeyPrefix = []byte{0x01}
)

// Events
const (
	EventTypeTransfer = "transfer"
	EventTypeMint     = "mint"
	EventTypeBurn     = "burn"

	AttributeKeyFrom      = "from"
	AttributeKeyTo        = "to"
	AttributeKeyRecipient = "recipient"
	AttributeKeyAmount    = "amount"
	AttributeKeyDenom     = "denom"
)

// Errors
var (
	ErrInsufficientBalance = sdkerrors.Register(ModuleName, 1, "insufficient balance")
	ErrInvalidAmount       = sdkerrors.Register(ModuleName, 2, "invalid amount")
	ErrInvalidAddress      = sdkerrors.Register(ModuleName, 3, "invalid address")
)

// Balance represents an account balance
type Balance struct {
	Address string  `json:"address" yaml:"address"`
	Denom   string  `json:"denom" yaml:"denom"`
	Amount  sdk.Int `json:"amount" yaml:"amount"`
}

// BalanceKey returns the store key for a balance
func BalanceKey(addr sdk.AccAddress, denom string) []byte {
	return append(BalancesPrefix(addr), []byte(denom)...)
}

// BalancesPrefix returns the prefix for all balances of an address
func BalancesPrefix(addr sdk.AccAddress) []byte {
	return append(BalanceKeyPrefix, addr.Bytes()...)
}

// ValidateBasic validates a balance
func (b Balance) ValidateBasic() error {
	if _, err := sdk.AccAddressFromBech32(b.Address); err != nil {
		return fmt.Errorf("invalid address: %w", err)
	}

	if err := sdk.ValidateDenom(b.Denom); err != nil {
		return err
	}

	if b.Amount.IsNegative() {
		return ErrInvalidAmount
	}

	return nil
}
