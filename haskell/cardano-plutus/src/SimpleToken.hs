{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE DeriveAnyClass      #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE TypeApplications    #-}
{-# LANGUAGE TypeFamilies        #-}
{-# LANGUAGE TypeOperators       #-}

module SimpleToken where

import           PlutusTx
import           PlutusTx.Prelude
import           Plutus.V2.Ledger.Api
import           Plutus.V2.Ledger.Contexts
import qualified Plutus.Script.Utils.V2.Scripts as Scripts
import           Ledger.Address
import qualified Ledger.Typed.Scripts           as Scripts
import           GHC.Generics                   (Generic)
import           Prelude                        (Show)

-- | Token parameters
data TokenParams = TokenParams
    { tpTokenName   :: !TokenName
    , tpSymbol      :: !BuiltinByteString
    , tpDecimals    :: !Integer
    , tpOwner       :: !PaymentPubKeyHash
    } deriving (Show, Generic)

PlutusTx.makeLift ''TokenParams

-- | Token datum - stores balance and allowances
data TokenDatum = TokenDatum
    { tdBalance     :: !Integer
    , tdAllowances  :: ![(PaymentPubKeyHash, Integer)]
    } deriving (Show, Generic)

PlutusTx.unstableMakeIsData ''TokenDatum

-- | Token actions
data TokenAction
    = Transfer
        { taTo     :: !PaymentPubKeyHash
        , taAmount :: !Integer
        }
    | Approve
        { aaSpender :: !PaymentPubKeyHash
        , aaAmount  :: !Integer
        }
    | TransferFrom
        { tfFrom   :: !PaymentPubKeyHash
        , tfTo     :: !PaymentPubKeyHash
        , tfAmount :: !Integer
        }
    | Mint
        { maTo     :: !PaymentPubKeyHash
        , maAmount :: !Integer
        }
    deriving Show

PlutusTx.unstableMakeIsData ''TokenAction

-- | Validator script
{-# INLINABLE mkTokenValidator #-}
mkTokenValidator :: TokenParams -> TokenDatum -> TokenAction -> ScriptContext -> Bool
mkTokenValidator params datum action ctx =
    case action of
        Transfer to amount ->
            traceIfFalse "insufficient balance" (tdBalance datum >= amount) &&
            traceIfFalse "invalid amount" (amount > 0) &&
            traceIfFalse "sender not authorized" checkSigned

        Approve spender amount ->
            traceIfFalse "invalid amount" (amount >= 0) &&
            traceIfFalse "owner not authorized" checkSigned

        TransferFrom from to amount ->
            let allowance = getAllowance (tdAllowances datum) (txSignedBy info)
            in  traceIfFalse "insufficient allowance" (allowance >= amount) &&
                traceIfFalse "invalid amount" (amount > 0)

        Mint to amount ->
            traceIfFalse "not authorized to mint" (checkOwner params) &&
            traceIfFalse "invalid amount" (amount > 0)
  where
    info :: TxInfo
    info = scriptContextTxInfo ctx

    checkSigned :: Bool
    checkSigned = txSignedBy info (unPaymentPubKeyHash $ txSignedBy info)

    checkOwner :: TokenParams -> Bool
    checkOwner tp = txSignedBy info (unPaymentPubKeyHash $ tpOwner tp)

    getAllowance :: [(PaymentPubKeyHash, Integer)] -> PubKeyHash -> Integer
    getAllowance allowances pkh =
        case lookup (PaymentPubKeyHash pkh) allowances of
            Just amt -> amt
            Nothing  -> 0

    txSignedBy :: TxInfo -> PubKeyHash
    txSignedBy info' = case txInfoSignatories info' of
        [pkh] -> pkh
        _     -> traceError "expected exactly one signatory"

-- | Typed validator
data TokenTypes
instance Scripts.ValidatorTypes TokenTypes where
    type instance DatumType TokenTypes = TokenDatum
    type instance RedeemerType TokenTypes = TokenAction

typedTokenValidator :: TokenParams -> Scripts.TypedValidator TokenTypes
typedTokenValidator params = Scripts.mkTypedValidator @TokenTypes
    ($$(PlutusTx.compile [|| mkTokenValidator ||]) `PlutusTx.applyCode` PlutusTx.liftCode params)
    $$(PlutusTx.compile [|| wrap ||])
  where
    wrap = Scripts.mkUntypedValidator @TokenDatum @TokenAction

-- | Validator script
tokenValidator :: TokenParams -> Validator
tokenValidator = Scripts.validatorScript . typedTokenValidator

-- | Script address
tokenAddress :: TokenParams -> Ledger.Address
tokenAddress = scriptAddress . tokenValidator

-- | Helper functions for off-chain code
tokenScript :: TokenParams -> Script
tokenScript = unValidatorScript . tokenValidator

tokenScriptShortBs :: TokenParams -> SerialisedScript
tokenScriptShortBs = serialiseCompiledCode . Scripts.validatorScript . typedTokenValidator
