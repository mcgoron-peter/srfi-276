(define (fl+ . args)
  (cond
    ((null? args) +0.0)
    ((null? (cdr args)) (car args))
    (else (fold srfi-144:fl+ (car args) (cdr args)))))

(define (fl* . args)
  (cond
    ((null? args) 1.0)
    ((null? (cdr args)) (car args))
    (else (fold srfi-144:fl* (car args) (cdr args)))))

(define (fl- x . rest)
  (cond
    ((null? rest) (srfi-144:fl- x))
    (else (fold srfi-144:fl- x rest))))

(define (fl/ x . rest)
  (cond
    ((null? rest) (srfi-144:fl/ x))
    (else (fold srfi-144:fl/ x rest))))