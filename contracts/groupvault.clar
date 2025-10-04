;; ------------------------------------------------------
;; GroupVault-STX
;; A decentralized group savings vault with pooled deposits,
;; shared withdrawals, and optional lending.
;; ------------------------------------------------------

(define-data-var vault-balance uint u0)
(define-data-var vault-counter uint u0)

(define-map vaults
  {id: uint}
  {
    name: (string-ascii 32),
    members: (list 20 principal),
    balance: uint,
    active: bool
  }
)

(define-map deposits
  {vault-id: uint, user: principal}
  {
    amount: uint
  }
)

(define-map loans
  {vault-id: uint, user: principal}
  {
    amount: uint,
    repaid: bool
  }
)

;; ------------------------------
;; ERRORS
;; ------------------------------

(define-constant ERR-NOT-MEMBER (err u100))
(define-constant ERR-NOT-ACTIVE (err u101))
(define-constant ERR-NO-DEPOSIT (err u102))
(define-constant ERR-NO-LOAN (err u103))
(define-constant ERR-ALREADY-LOAN (err u104))

;; ------------------------------
;; FUNCTIONS
;; ------------------------------

;; Create a new vault with members
(define-public (create-vault (name (string-ascii 32)) (members (list 20 principal)))
  (let ((id (+ (var-get vault-counter) u1)))
    (begin
      (var-set vault-counter id)
      (map-set vaults {id: id}
        {
          name: name,
          members: members,
          balance: u0,
          active: true
        })
      (ok id)
    )
  )
)

;; Deposit into vault
(define-public (deposit (vault-id uint) (amount uint))
  (let ((vault (map-get? vaults {id: vault-id})))
    (match vault
      v
      (if (get active v)
        (if (is-some (index-of (get members v) tx-sender))
          (begin
            ;; Added try! and fixed contract-principal to as-contract tx-sender
            (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
            (map-set deposits {vault-id: vault-id, user: tx-sender}
              { amount: (+ amount (default-to u0 (get amount (map-get? deposits {vault-id: vault-id, user: tx-sender})))) })
            (map-set vaults {id: vault-id}
              {
                name: (get name v),
                members: (get members v),
                balance: (+ (get balance v) amount),
                active: true
              })
            ;; Removed emoji, replaced with ASCII-only text
            (ok "Deposit successful")
          )
          ERR-NOT-MEMBER
        )
        ERR-NOT-ACTIVE
      )
      (err u404) ;; Vault not found
    )
  )
)

;; Request a loan from the vault
(define-public (request-loan (vault-id uint) (amount uint))
  (let ((vault (map-get? vaults {id: vault-id})))
    (match vault
      v
      (if (is-some (index-of (get members v) tx-sender))
        (if (is-none (map-get? loans {vault-id: vault-id, user: tx-sender}))
          (if (>= (get balance v) amount)
            (begin
              ;; Added try! and fixed contract-principal to as-contract tx-sender
              (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
              (map-set loans {vault-id: vault-id, user: tx-sender}
                { amount: amount, repaid: false })
              (map-set vaults {id: vault-id}
                {
                  name: (get name v),
                  members: (get members v),
                  balance: (- (get balance v) amount),
                  active: true
                })
              ;; Removed emoji, replaced with ASCII-only text
              (ok "Loan granted")
            )
            (err u200) ;; Insufficient balance
          )
          ERR-ALREADY-LOAN
        )
        ERR-NOT-MEMBER
      )
      (err u404)
    )
  )
)

;; Repay a loan
(define-public (repay-loan (vault-id uint) (amount uint))
  (let ((loan (map-get? loans {vault-id: vault-id, user: tx-sender})))
    (match loan
      l
      (if (not (get repaid l))
        (begin
          ;; Added try! and fixed contract-principal to as-contract tx-sender
          (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
          (map-set loans {vault-id: vault-id, user: tx-sender}
            { amount: (get amount l), repaid: true })
          ;; Removed emoji, replaced with ASCII-only text
          (ok "Loan repaid")
        )
        ERR-NO-LOAN
      )
      ERR-NO-LOAN
    )
  )
)
