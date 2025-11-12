package types

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"
)

// Message types for the token module
const (
	TypeMsgTransfer = "transfer"
	TypeMsgMint     = "mint"
	TypeMsgBurn     = "burn"
)

var (
	_ sdk.Msg = &MsgTransfer{}
	_ sdk.Msg = &MsgMint{}
	_ sdk.Msg = &MsgBurn{}
)

// MsgTransfer defines a message to transfer tokens
type MsgTransfer struct {
	FromAddress string  `json:"from_address" yaml:"from_address"`
	ToAddress   string  `json:"to_address" yaml:"to_address"`
	Amount      sdk.Int `json:"amount" yaml:"amount"`
	Denom       string  `json:"denom" yaml:"denom"`
}

// NewMsgTransfer creates a new MsgTransfer instance
func NewMsgTransfer(fromAddr, toAddr string, amount sdk.Int, denom string) *MsgTransfer {
	return &MsgTransfer{
		FromAddress: fromAddr,
		ToAddress:   toAddr,
		Amount:      amount,
		Denom:       denom,
	}
}

// Route implements sdk.Msg
func (msg MsgTransfer) Route() string { return RouterKey }

// Type implements sdk.Msg
func (msg MsgTransfer) Type() string { return TypeMsgTransfer }

// GetSigners implements sdk.Msg
func (msg MsgTransfer) GetSigners() []sdk.AccAddress {
	fromAddress, err := sdk.AccAddressFromBech32(msg.FromAddress)
	if err != nil {
		panic(err)
	}
	return []sdk.AccAddress{fromAddress}
}

// GetSignBytes implements sdk.Msg
func (msg MsgTransfer) GetSignBytes() []byte {
	return sdk.MustSortJSON(ModuleCdc.MustMarshalJSON(&msg))
}

// ValidateBasic implements sdk.Msg
func (msg MsgTransfer) ValidateBasic() error {
	if _, err := sdk.AccAddressFromBech32(msg.FromAddress); err != nil {
		return sdkerrors.Wrapf(ErrInvalidAddress, "invalid from address: %s", err)
	}

	if _, err := sdk.AccAddressFromBech32(msg.ToAddress); err != nil {
		return sdkerrors.Wrapf(ErrInvalidAddress, "invalid to address: %s", err)
	}

	if msg.Amount.IsNegative() || msg.Amount.IsZero() {
		return ErrInvalidAmount
	}

	if err := sdk.ValidateDenom(msg.Denom); err != nil {
		return err
	}

	return nil
}

// MsgMint defines a message to mint tokens
type MsgMint struct {
	ToAddress string  `json:"to_address" yaml:"to_address"`
	Amount    sdk.Int `json:"amount" yaml:"amount"`
	Denom     string  `json:"denom" yaml:"denom"`
}

// NewMsgMint creates a new MsgMint instance
func NewMsgMint(toAddr string, amount sdk.Int, denom string) *MsgMint {
	return &MsgMint{
		ToAddress: toAddr,
		Amount:    amount,
		Denom:     denom,
	}
}

// Route implements sdk.Msg
func (msg MsgMint) Route() string { return RouterKey }

// Type implements sdk.Msg
func (msg MsgMint) Type() string { return TypeMsgMint }

// GetSigners implements sdk.Msg
func (msg MsgMint) GetSigners() []sdk.AccAddress {
	toAddress, err := sdk.AccAddressFromBech32(msg.ToAddress)
	if err != nil {
		panic(err)
	}
	return []sdk.AccAddress{toAddress}
}

// GetSignBytes implements sdk.Msg
func (msg MsgMint) GetSignBytes() []byte {
	return sdk.MustSortJSON(ModuleCdc.MustMarshalJSON(&msg))
}

// ValidateBasic implements sdk.Msg
func (msg MsgMint) ValidateBasic() error {
	if _, err := sdk.AccAddressFromBech32(msg.ToAddress); err != nil {
		return sdkerrors.Wrapf(ErrInvalidAddress, "invalid address: %s", err)
	}

	if msg.Amount.IsNegative() || msg.Amount.IsZero() {
		return ErrInvalidAmount
	}

	if err := sdk.ValidateDenom(msg.Denom); err != nil {
		return err
	}

	return nil
}

// MsgBurn defines a message to burn tokens
type MsgBurn struct {
	FromAddress string  `json:"from_address" yaml:"from_address"`
	Amount      sdk.Int `json:"amount" yaml:"amount"`
	Denom       string  `json:"denom" yaml:"denom"`
}

// NewMsgBurn creates a new MsgBurn instance
func NewMsgBurn(fromAddr string, amount sdk.Int, denom string) *MsgBurn {
	return &MsgBurn{
		FromAddress: fromAddr,
		Amount:      amount,
		Denom:       denom,
	}
}

// Route implements sdk.Msg
func (msg MsgBurn) Route() string { return RouterKey }

// Type implements sdk.Msg
func (msg MsgBurn) Type() string { return TypeMsgBurn }

// GetSigners implements sdk.Msg
func (msg MsgBurn) GetSigners() []sdk.AccAddress {
	fromAddress, err := sdk.AccAddressFromBech32(msg.FromAddress)
	if err != nil {
		panic(err)
	}
	return []sdk.AccAddress{fromAddress}
}

// GetSignBytes implements sdk.Msg
func (msg MsgBurn) GetSignBytes() []byte {
	return sdk.MustSortJSON(ModuleCdc.MustMarshalJSON(&msg))
}

// ValidateBasic implements sdk.Msg
func (msg MsgBurn) ValidateBasic() error {
	if _, err := sdk.AccAddressFromBech32(msg.FromAddress); err != nil {
		return sdkerrors.Wrapf(ErrInvalidAddress, "invalid address: %s", err)
	}

	if msg.Amount.IsNegative() || msg.Amount.IsZero() {
		return ErrInvalidAmount
	}

	if err := sdk.ValidateDenom(msg.Denom); err != nil {
		return err
	}

	return nil
}
