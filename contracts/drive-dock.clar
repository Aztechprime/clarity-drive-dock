;; Drive Dock Main Contract

;; Data Variables
(define-map rides
  { ride-id: uint }
  {
    driver: principal,
    origin: (string-utf8 100),
    destination: (string-utf8 100),
    departure-time: uint,
    seats: uint,
    price: uint,
    status: (string-ascii 20)
  }
)

(define-data-var ride-counter uint u0)

;; Error constants
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-UNAUTHORIZED (err u401))
(define-constant ERR-INVALID-STATUS (err u400))

;; Create new ride listing
(define-public (create-ride (origin (string-utf8 100)) 
                          (destination (string-utf8 100))
                          (departure-time uint)
                          (seats uint)
                          (price uint))
  (let ((ride-id (var-get ride-counter)))
    (map-set rides
      { ride-id: ride-id }
      {
        driver: tx-sender,
        origin: origin,
        destination: destination,
        departure-time: departure-time,
        seats: seats,
        price: price,
        status: "OPEN"
      }
    )
    (var-set ride-counter (+ ride-id u1))
    (ok ride-id))
)

;; Book a ride
(define-public (book-ride (ride-id uint))
  (let ((ride (unwrap! (map-get? rides { ride-id: ride-id }) ERR-NOT-FOUND)))
    (asserts! (is-eq (get status ride) "OPEN") ERR-INVALID-STATUS)
    ;; Additional booking logic here
    (ok true))
)
