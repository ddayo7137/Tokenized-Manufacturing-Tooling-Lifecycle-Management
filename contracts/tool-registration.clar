;; Tool Registration Contract
;; Records details of production equipment

(define-data-var next-tool-id uint u0)

(define-map tools
  { tool-id: uint }
  {
    name: (string-ascii 100),
    tool-type: (string-ascii 50),
    manufacturer: (string-ascii 100),
    serial-number: (string-ascii 50),
    purchase-date: uint,
    expected-lifetime: uint,
    owner: principal
  }
)

(define-read-only (get-tool (tool-id uint))
  (map-get? tools { tool-id: tool-id })
)

(define-read-only (get-next-tool-id)
  (var-get next-tool-id)
)

(define-public (register-tool
    (name (string-ascii 100))
    (tool-type (string-ascii 50))
    (manufacturer (string-ascii 100))
    (serial-number (string-ascii 50))
    (purchase-date uint)
    (expected-lifetime uint)
  )
  (let
    (
      (tool-id (var-get next-tool-id))
    )
    (map-set tools
      { tool-id: tool-id }
      {
        name: name,
        tool-type: tool-type,
        manufacturer: manufacturer,
        serial-number: serial-number,
        purchase-date: purchase-date,
        expected-lifetime: expected-lifetime,
        owner: tx-sender
      }
    )
    (var-set next-tool-id (+ tool-id u1))
    (ok tool-id)
  )
)

(define-public (transfer-tool-ownership (tool-id uint) (new-owner principal))
  (let
    (
      (tool (unwrap! (get-tool tool-id) (err u404)))
    )
    (asserts! (is-eq tx-sender (get owner tool)) (err u403))
    (map-set tools
      { tool-id: tool-id }
      (merge tool { owner: new-owner })
    )
    (ok true)
  )
)
