;; Usage Tracking Contract
;; Monitors operational hours and wear

(define-map tool-usage
  { tool-id: uint }
  {
    total-hours: uint,
    last-usage-date: uint,
    wear-level: uint  ;; 0-100 scale where 100 is completely worn out
  }
)

(define-map usage-logs
  { tool-id: uint, log-id: uint }
  {
    date: uint,
    hours: uint,
    operator: principal,
    notes: (string-ascii 200)
  }
)

(define-map tool-usage-counters
  { tool-id: uint }
  { next-log-id: uint }
)

(define-read-only (get-tool-usage (tool-id uint))
  (default-to
    { total-hours: u0, last-usage-date: u0, wear-level: u0 }
    (map-get? tool-usage { tool-id: tool-id })
  )
)

(define-read-only (get-usage-log (tool-id uint) (log-id uint))
  (map-get? usage-logs { tool-id: tool-id, log-id: log-id })
)

(define-read-only (get-next-log-id (tool-id uint))
  (default-to
    { next-log-id: u0 }
    (map-get? tool-usage-counters { tool-id: tool-id })
  )
)

(define-public (log-usage
    (tool-id uint)
    (hours uint)
    (date uint)
    (notes (string-ascii 200))
  )
  (let
    (
      (current-usage (get-tool-usage tool-id))
      (current-counter (get-next-log-id tool-id))
      (log-id (get next-log-id current-counter))
      (new-total-hours (+ (get total-hours current-usage) hours))
      (new-wear-level (calculate-wear-level tool-id new-total-hours))
    )
    ;; Update usage stats
    (map-set tool-usage
      { tool-id: tool-id }
      {
        total-hours: new-total-hours,
        last-usage-date: date,
        wear-level: new-wear-level
      }
    )

    ;; Log the usage event
    (map-set usage-logs
      { tool-id: tool-id, log-id: log-id }
      {
        date: date,
        hours: hours,
        operator: tx-sender,
        notes: notes
      }
    )

    ;; Update the counter
    (map-set tool-usage-counters
      { tool-id: tool-id }
      { next-log-id: (+ log-id u1) }
    )

    (ok log-id)
  )
)

;; Helper function to calculate wear level based on total hours
;; This is a simplified version - in a real implementation, this would be more sophisticated
(define-private (calculate-wear-level (tool-id uint) (total-hours uint))
  ;; For simplicity, we'll assume a linear wear model
  ;; In a real implementation, you would get the expected lifetime from the tool registration
  ;; and calculate wear based on that
  (let
    (
      (expected-lifetime u10000) ;; Placeholder - in reality, get this from tool registration
    )
    (if (> total-hours expected-lifetime)
      u100 ;; Max wear level
      (/ (* total-hours u100) expected-lifetime)
    )
  )
)
