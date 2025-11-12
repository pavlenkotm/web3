;; SIP-010 Fungible Token Standard Implementation
;; Simple token contract for Stacks blockchain

;; Define the token
(define-fungible-token simple-token)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant err-invalid-amount (err u102))

;; Storage
(define-data-var token-name (string-ascii 32) "SimpleToken")
(define-data-var token-symbol (string-ascii 10) "SMPL")
(define-data-var token-decimals uint u6)
(define-data-var token-uri (optional (string-utf8 256)) none)

;; SIP-010 Functions

;; Get token name
(define-read-only (get-name)
  (ok (var-get token-name))
)

;; Get token symbol
(define-read-only (get-symbol)
  (ok (var-get token-symbol))
)

;; Get token decimals
(define-read-only (get-decimals)
  (ok (var-get token-decimals))
)

;; Get total supply
(define-read-only (get-total-supply)
  (ok (ft-get-supply simple-token))
)

;; Get token URI
(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

;; Get balance of an account
(define-read-only (get-balance (account principal))
  (ok (ft-get-balance simple-token account))
)

;; Transfer tokens
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) err-owner-only)
    (asserts! (> amount u0) err-invalid-amount)
    (try! (ft-transfer? simple-token amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

;; Administrative Functions

;; Mint new tokens (only contract owner)
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> amount u0) err-invalid-amount)
    (ft-mint? simple-token amount recipient)
  )
)

;; Burn tokens
(define-public (burn (amount uint) (sender principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-owner-only)
    (asserts! (> amount u0) err-invalid-amount)
    (ft-burn? simple-token amount sender)
  )
)

;; Set token URI (only contract owner)
(define-public (set-token-uri (uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set token-uri (some uri))
    (ok true)
  )
)

;; Initialize the contract with initial supply
(begin
  (try! (ft-mint? simple-token u1000000 contract-owner))
  (ok true)
)
