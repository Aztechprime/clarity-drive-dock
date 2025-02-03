;; User Registry Contract

;; Data Maps
(define-map users
  { user: principal }
  {
    name: (string-utf8 50),
    rating: uint,
    total-rides: uint,
    neighborhood: (string-utf8 100)
  }
)

(define-map ratings
  { user: principal, rater: principal }
  { score: uint }
)

;; Register new user
(define-public (register-user (name (string-utf8 50)) (neighborhood (string-utf8 100)))
  (map-set users
    { user: tx-sender }
    {
      name: name,
      rating: u0,
      total-rides: u0,
      neighborhood: neighborhood
    }
  )
  (ok true)
)

;; Rate a user
(define-public (rate-user (user principal) (score uint))
  (begin
    (map-set ratings
      { user: user, rater: tx-sender }
      { score: score }
    )
    (ok true))
)
