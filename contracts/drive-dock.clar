;; Drive Dock Main Contract

;; Constants
(define-constant STATUS-OPEN "OPEN")
(define-constant STATUS-BOOKED "BOOKED")
(define-constant STATUS-COMPLETED "COMPLETED")
(define-constant STATUS-CANCELLED "CANCELLED")

;; Error constants
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-UNAUTHORIZED (err u401))
(define-constant ERR-INVALID-STATUS (err u400))
(define-constant ERR-NO-SEATS (err u402))
(define-constant ERR-ALREADY-BOOKED (err u403))
(define-constant ERR-INVALID-PRICE (err u405))
(define-constant MIN-PRICE u1)
(define-constant MAX-PRICE u1000)

;; Data Variables
(define-map rides
  { ride-id: uint }
  {
    driver: principal,
    origin: (string-utf8 100),
    destination: (string-utf8 100),
    departure-time: uint,
    seats: uint,
    seats-taken: uint,
    price: uint,
    status: (string-ascii 20),
    neighborhood: (string-utf8 100)
  }
)

(define-map ride-feedback
  { ride-id: uint, user: principal }
  {
    rating: uint,
    comment: (string-utf8 200)
  }
)

(define-data-var ride-counter uint u0)

;; Events
(define-data-var last-event-id uint u0)

(define-map events
  { event-id: uint }
  {
    event-type: (string-ascii 20),
    ride-id: uint,
    user: principal,
    timestamp: uint
  }
)

;; Private Functions
(define-private (validate-price (price uint))
  (and (>= price MIN-PRICE) (<= price MAX-PRICE))
)

(define-private (emit-event (event-type (string-ascii 20)) (ride-id uint))
  (let ((event-id (var-get last-event-id)))
    (map-set events
      { event-id: event-id }
      {
        event-type: event-type,
        ride-id: ride-id,
        user: tx-sender,
        timestamp: block-height
      }
    )
    (var-set last-event-id (+ event-id u1))
    (ok event-id)
  )
)

;; Public Functions
(define-public (create-ride (origin (string-utf8 100)) 
                          (destination (string-utf8 100))
                          (departure-time uint)
                          (seats uint)
                          (price uint)
                          (neighborhood (string-utf8 100)))
  (let ((ride-id (var-get ride-counter)))
    (asserts! (validate-price price) ERR-INVALID-PRICE)
    (map-set rides
      { ride-id: ride-id }
      {
        driver: tx-sender,
        origin: origin,
        destination: destination,
        departure-time: departure-time,
        seats: seats,
        seats-taken: u0,
        price: price,
        status: STATUS-OPEN,
        neighborhood: neighborhood
      }
    )
    (var-set ride-counter (+ ride-id u1))
    (emit-event "RIDE_CREATED" ride-id)
    (ok ride-id))
)

;; Read-only functions
(define-read-only (get-ride (ride-id uint))
  (map-get? rides { ride-id: ride-id })
)

(define-read-only (get-rides-by-neighborhood (neighborhood (string-utf8 100)))
  (filter filter-by-neighborhood (map-get? rides))
)

;; Additional functions remain unchanged...
