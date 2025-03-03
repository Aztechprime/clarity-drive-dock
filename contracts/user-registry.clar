;; User Registry Contract

;; Constants
(define-constant ERR-INVALID-RATING (err u400))
(define-constant MIN-RATING u1)
(define-constant MAX-RATING u5)

;; Data Maps
(define-map users
  { user: principal }
  {
    name: (string-utf8 50),
    rating: uint,
    total-ratings: uint,
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
      total-ratings: u0,
      total-rides: u0,
      neighborhood: neighborhood
    }
  )
  (ok true)
)

;; Rate a user
(define-public (rate-user (user principal) (score uint))
  (begin
    (asserts! (and (>= score MIN-RATING) (<= score MAX-RATING)) ERR-INVALID-RATING)
    (let ((current-user (unwrap! (map-get? users { user: user }) ERR-NOT-FOUND)))
      (map-set ratings
        { user: user, rater: tx-sender }
        { score: score }
      )
      (map-set users
        { user: user }
        (merge current-user {
          rating: (/ (+ (* (get rating current-user) (get total-ratings current-user)) score)
                    (+ (get total-ratings current-user) u1)),
          total-ratings: (+ (get total-ratings current-user) u1)
        })
      )
      (ok true))
  )
)

;; Get user profile
(define-read-only (get-user-profile (user principal))
  (map-get? users { user: user })
)
