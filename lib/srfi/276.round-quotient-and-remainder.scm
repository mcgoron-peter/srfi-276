(define (flround-quotient x y)
  (flround (fl/ x y)))

(define (flround-remainder x y)
  (let-values (((ignored remainder) (flremquo x y)))
    remainder))
