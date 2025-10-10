;; title: Community-Microgrid-Energy-Trading

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-registered (err u101))
(define-constant err-already-registered (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-invalid-price (err u104))
(define-constant err-insufficient-energy (err u105))
(define-constant err-listing-not-found (err u106))
(define-constant err-unauthorized (err u107))
(define-constant err-payment-failed (err u108))
(define-constant err-already-filled (err u109))

(define-data-var listing-nonce uint u0)
(define-data-var transaction-nonce uint u0)
(define-data-var total-energy-traded uint u0)

(define-map producers
    principal
    {
        total-produced: uint,
        total-sold: uint,
        balance: uint,
        active: bool,
        registered-at: uint
    }
)

(define-map consumers
    principal
    {
        total-purchased: uint,
        total-consumed: uint,
        active: bool,
        registered-at: uint
    }
)

(define-map energy-listings
    uint
    {
        producer: principal,
        energy-amount: uint,
        price-per-unit: uint,
        total-price: uint,
        filled: bool,
        buyer: (optional principal),
        created-at: uint,
        filled-at: (optional uint)
    }
)

(define-map transactions
    uint
    {
        listing-id: uint,
        seller: principal,
        buyer: principal,
        energy-amount: uint,
        total-price: uint,
        timestamp: uint
    }
)

(define-public (register-producer)
    (let
        (
            (caller tx-sender)
        )
        (asserts! (is-none (map-get? producers caller)) err-already-registered)
        (ok (map-set producers caller {
            total-produced: u0,
            total-sold: u0,
            balance: u0,
            active: true,
            registered-at: stacks-block-height
        }))
    )
)

(define-public (register-consumer)
    (let
        (
            (caller tx-sender)
        )
        (asserts! (is-none (map-get? consumers caller)) err-already-registered)
        (ok (map-set consumers caller {
            total-purchased: u0,
            total-consumed: u0,
            active: true,
            registered-at: stacks-block-height
        }))
    )
)

(define-public (add-energy-production (amount uint))
    (let
        (
            (caller tx-sender)
            (producer-data (unwrap! (map-get? producers caller) err-not-registered))
        )
        (asserts! (> amount u0) err-invalid-amount)
        (asserts! (get active producer-data) err-unauthorized)
        (ok (map-set producers caller (merge producer-data {
            total-produced: (+ (get total-produced producer-data) amount),
            balance: (+ (get balance producer-data) amount)
        })))
    )
)

(define-public (create-listing (energy-amount uint) (price-per-unit uint))
    (let
        (
            (caller tx-sender)
            (producer-data (unwrap! (map-get? producers caller) err-not-registered))
            (current-nonce (var-get listing-nonce))
            (total-price (* energy-amount price-per-unit))
        )
        (asserts! (> energy-amount u0) err-invalid-amount)
        (asserts! (> price-per-unit u0) err-invalid-price)
        (asserts! (>= (get balance producer-data) energy-amount) err-insufficient-energy)
        (asserts! (get active producer-data) err-unauthorized)
        
        (map-set producers caller (merge producer-data {
            balance: (- (get balance producer-data) energy-amount)
        }))
        
        (map-set energy-listings current-nonce {
            producer: caller,
            energy-amount: energy-amount,
            price-per-unit: price-per-unit,
            total-price: total-price,
            filled: false,
            buyer: none,
            created-at: stacks-block-height,
            filled-at: none
        })
        
        (var-set listing-nonce (+ current-nonce u1))
        (ok current-nonce)
    )
)

(define-public (buy-energy (listing-id uint))
    (let
        (
            (caller tx-sender)
            (listing (unwrap! (map-get? energy-listings listing-id) err-listing-not-found))
            (consumer-data (unwrap! (map-get? consumers caller) err-not-registered))
            (producer-data (unwrap! (map-get? producers (get producer listing)) err-not-registered))
            (current-tx-nonce (var-get transaction-nonce))
        )
        (asserts! (not (get filled listing)) err-already-filled)
        (asserts! (get active consumer-data) err-unauthorized)
        
        (unwrap! (stx-transfer? (get total-price listing) caller (get producer listing)) err-payment-failed)
        
        (map-set energy-listings listing-id (merge listing {
            filled: true,
            buyer: (some caller),
            filled-at: (some stacks-block-height)
        }))
        
        (map-set producers (get producer listing) (merge producer-data {
            total-sold: (+ (get total-sold producer-data) (get energy-amount listing))
        }))
        
        (map-set consumers caller (merge consumer-data {
            total-purchased: (+ (get total-purchased consumer-data) (get energy-amount listing)),
            total-consumed: (+ (get total-consumed consumer-data) (get energy-amount listing))
        }))
        
        (map-set transactions current-tx-nonce {
            listing-id: listing-id,
            seller: (get producer listing),
            buyer: caller,
            energy-amount: (get energy-amount listing),
            total-price: (get total-price listing),
            timestamp: stacks-block-height
        })
        
        (var-set transaction-nonce (+ current-tx-nonce u1))
        (var-set total-energy-traded (+ (var-get total-energy-traded) (get energy-amount listing)))
        
        (ok current-tx-nonce)
    )
)

(define-public (cancel-listing (listing-id uint))
    (let
        (
            (caller tx-sender)
            (listing (unwrap! (map-get? energy-listings listing-id) err-listing-not-found))
            (producer-data (unwrap! (map-get? producers caller) err-not-registered))
        )
        (asserts! (is-eq caller (get producer listing)) err-unauthorized)
        (asserts! (not (get filled listing)) err-already-filled)
        
        (map-set producers caller (merge producer-data {
            balance: (+ (get balance producer-data) (get energy-amount listing))
        }))
        
        (map-set energy-listings listing-id (merge listing {
            filled: true,
            filled-at: (some stacks-block-height)
        }))
        
        (ok true)
    )
)

(define-public (deactivate-producer)
    (let
        (
            (caller tx-sender)
            (producer-data (unwrap! (map-get? producers caller) err-not-registered))
        )
        (ok (map-set producers caller (merge producer-data {
            active: false
        })))
    )
)

(define-public (deactivate-consumer)
    (let
        (
            (caller tx-sender)
            (consumer-data (unwrap! (map-get? consumers caller) err-not-registered))
        )
        (ok (map-set consumers caller (merge consumer-data {
            active: false
        })))
    )
)

(define-read-only (get-producer (producer principal))
    (ok (map-get? producers producer))
)

(define-read-only (get-consumer (consumer principal))
    (ok (map-get? consumers consumer))
)

(define-read-only (get-listing (listing-id uint))
    (ok (map-get? energy-listings listing-id))
)

(define-read-only (get-transaction (transaction-id uint))
    (ok (map-get? transactions transaction-id))
)

(define-read-only (get-total-energy-traded)
    (ok (var-get total-energy-traded))
)

(define-read-only (get-listing-count)
    (ok (var-get listing-nonce))
)

(define-read-only (get-transaction-count)
    (ok (var-get transaction-nonce))
)
