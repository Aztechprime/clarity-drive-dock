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
    status: (string-ascii 20)
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
        seats-taken: u0,
        price: price,
        status: STATUS-OPEN
      }
    )
    (var-set ride-counter (+ ride-id u1))
    (emit-event "RIDE_CREATED" ride-id)
    (ok ride-id))
)

;; Book a ride
(define-public (book-ride (ride-id uint))
  (let ((ride (unwrap! (map-get? rides { ride-id: ride-id }) ERR-NOT-FOUND)))
    (asserts! (is-eq (get status ride) STATUS-OPEN) ERR-INVALID-STATUS)
    (asserts! (< (get seats-taken ride) (get seats ride)) ERR-NO-SEATS)
    (map-set rides
      { ride-id: ride-id }
      (merge ride {
        seats-taken: (+ (get seats-taken ride) u1),
        status: (if (>= (+ (get seats-taken ride) u1) (get seats ride))
          STATUS-BOOKED
          STATUS-OPEN)
      })
    )
    (emit-event "RIDE_BOOKED" ride-id)
    (ok true))
)

;; Cancel a ride
(define-public (cancel-ride (ride-id uint))
  (let ((ride (unwrap! (map-get? rides { ride-id: ride-id }) ERR-NOT-FOUND)))
    (asserts! (or
      (is-eq tx-sender (get driver ride))
      (is-eq (get status ride) STATUS-OPEN)
    ) ERR-UNAUTHORIZED)
    (map-set rides
      { ride-id: ride-id }
      (merge ride { status: STATUS-CANCELLED })
    )
    (emit-event "RIDE_CANCELLED" ride-id)
    (ok true))
)

;; Complete a ride
(define-public (complete-ride (ride-id uint))
  (let ((ride (unwrap! (map-get? rides { ride-id: ride-id }) ERR-NOT-FOUND)))
    (asserts! (is-eq tx-sender (get driver ride)) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get status ride) STATUS-BOOKED) ERR-INVALID-STATUS)
    (map-set rides
      { ride-id: ride-id }
      (merge ride { status: STATUS-COMPLETED })
    )
    (emit-event "RIDE_COMPLETED" ride-id)
    (ok true))
)
