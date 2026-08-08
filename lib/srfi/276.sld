(define-library (srfi 276)
  (import (scheme base)
          (scheme case-lambda)
          (rename (except (srfi 144)
                          fl-integer-exponent-zero
                          fl-integer-exponent-nan
                          flmax flmin)
                  (flsign-bit srfi-144:flsign-bit)
                  (flinteger-exponent srfi-144:flinteger-exponent)
                  (flnormalized? flnormal?)
                  (fldenormalized? flsubnormal?)
                  ))

  ;; Get some reasonably large numbers.
  (cond-expand
    ((library (srfi 143))
     (import (rename (only (srfi 143) fx-greatest fx-least)
                     (fx-greatest large-positive-integer)
                     (fx-least large-negative-integer))))
    ((library (rnrs arithmetic fixnums))
     (import (only (rnrs arithmetic fixnums) least-fixnum greatest-fixnum))
     (begin (define large-positive-integer (greatest-fixnum))
            (define large-negative-integer (least-fixnum))))
    (else (begin
            (define large-positive-integer
              (- (expt 2 24) 1))
            (define large-negative-integer
              (- (expt 2 24))))))

  (include "276.sign-negative.scm")
  (include "276.integer-exponent.scm")
  (include "276.flonum.scm")
  (include "276.new-constants.scm")
  (include "276.util.scm")
  (include "276.noteq.scm")
  (include "276.total.scm")
)
