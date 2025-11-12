package keeper

import (
	"fmt"

	"github.com/cosmos/cosmos-sdk/codec"
	storetypes "github.com/cosmos/cosmos-sdk/store/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/tendermint/tendermint/libs/log"

	"github.com/example/token/x/token/types"
)

// Keeper maintains the link to data storage and exposes getter/setter methods
type Keeper struct {
	cdc      codec.BinaryCodec
	storeKey storetypes.StoreKey
	memKey   storetypes.StoreKey
}

// NewKeeper creates a new token Keeper instance
func NewKeeper(
	cdc codec.BinaryCodec,
	storeKey,
	memKey storetypes.StoreKey,
) *Keeper {
	return &Keeper{
		cdc:      cdc,
		storeKey: storeKey,
		memKey:   memKey,
	}
}

// Logger returns a module-specific logger
func (k Keeper) Logger(ctx sdk.Context) log.Logger {
	return ctx.Logger().With("module", fmt.Sprintf("x/%s", types.ModuleName))
}

// GetBalance returns the balance of an account
func (k Keeper) GetBalance(ctx sdk.Context, addr sdk.AccAddress, denom string) sdk.Int {
	store := ctx.KVStore(k.storeKey)
	key := types.BalanceKey(addr, denom)

	bz := store.Get(key)
	if bz == nil {
		return sdk.ZeroInt()
	}

	var balance sdk.Int
	k.cdc.MustUnmarshal(bz, &balance)
	return balance
}

// SetBalance sets the balance of an account
func (k Keeper) SetBalance(ctx sdk.Context, addr sdk.AccAddress, denom string, amount sdk.Int) {
	store := ctx.KVStore(k.storeKey)
	key := types.BalanceKey(addr, denom)

	bz := k.cdc.MustMarshal(&amount)
	store.Set(key, bz)
}

// Transfer transfers tokens from one account to another
func (k Keeper) Transfer(ctx sdk.Context, from, to sdk.AccAddress, denom string, amount sdk.Int) error {
	if amount.IsNegative() {
		return types.ErrInvalidAmount
	}

	fromBalance := k.GetBalance(ctx, from, denom)
	if fromBalance.LT(amount) {
		return types.ErrInsufficientBalance
	}

	toBalance := k.GetBalance(ctx, to, denom)

	k.SetBalance(ctx, from, denom, fromBalance.Sub(amount))
	k.SetBalance(ctx, to, denom, toBalance.Add(amount))

	// Emit transfer event
	ctx.EventManager().EmitEvent(
		sdk.NewEvent(
			types.EventTypeTransfer,
			sdk.NewAttribute(types.AttributeKeyFrom, from.String()),
			sdk.NewAttribute(types.AttributeKeyTo, to.String()),
			sdk.NewAttribute(types.AttributeKeyAmount, amount.String()),
			sdk.NewAttribute(types.AttributeKeyDenom, denom),
		),
	)

	return nil
}

// Mint mints new tokens to an account
func (k Keeper) Mint(ctx sdk.Context, addr sdk.AccAddress, denom string, amount sdk.Int) error {
	if amount.IsNegative() || amount.IsZero() {
		return types.ErrInvalidAmount
	}

	balance := k.GetBalance(ctx, addr, denom)
	k.SetBalance(ctx, addr, denom, balance.Add(amount))

	// Emit mint event
	ctx.EventManager().EmitEvent(
		sdk.NewEvent(
			types.EventTypeMint,
			sdk.NewAttribute(types.AttributeKeyRecipient, addr.String()),
			sdk.NewAttribute(types.AttributeKeyAmount, amount.String()),
			sdk.NewAttribute(types.AttributeKeyDenom, denom),
		),
	)

	return nil
}

// Burn burns tokens from an account
func (k Keeper) Burn(ctx sdk.Context, addr sdk.AccAddress, denom string, amount sdk.Int) error {
	if amount.IsNegative() || amount.IsZero() {
		return types.ErrInvalidAmount
	}

	balance := k.GetBalance(ctx, addr, denom)
	if balance.LT(amount) {
		return types.ErrInsufficientBalance
	}

	k.SetBalance(ctx, addr, denom, balance.Sub(amount))

	// Emit burn event
	ctx.EventManager().EmitEvent(
		sdk.NewEvent(
			types.EventTypeBurn,
			sdk.NewAttribute(types.AttributeKeyFrom, addr.String()),
			sdk.NewAttribute(types.AttributeKeyAmount, amount.String()),
			sdk.NewAttribute(types.AttributeKeyDenom, denom),
		),
	)

	return nil
}

// GetAllBalances returns all balances for an account
func (k Keeper) GetAllBalances(ctx sdk.Context, addr sdk.AccAddress) []types.Balance {
	store := ctx.KVStore(k.storeKey)
	iterator := sdk.KVStorePrefixIterator(store, types.BalancesPrefix(addr))
	defer iterator.Close()

	balances := []types.Balance{}
	for ; iterator.Valid(); iterator.Next() {
		var amount sdk.Int
		k.cdc.MustUnmarshal(iterator.Value(), &amount)

		denom := string(iterator.Key()[len(types.BalancesPrefix(addr)):])
		balances = append(balances, types.Balance{
			Address: addr.String(),
			Denom:   denom,
			Amount:  amount,
		})
	}

	return balances
}
