,(import (rename (except (srfi 144)
                          fl-integer-exponent-zero
                          fl-integer-exponent-nan
                          flmax flmin)
		  (flonum srfi-144:flonum)
                  (flsign-bit srfi-144:flsign-bit)
                  (flinteger-exponent srfi-144:flinteger-exponent)
                  (flnormalized? flnormal?)
                  (fldenormalized? flsubnormal?)))
,(import (rename (only (srfi 143) fx-greatest fx-least)
                     (fx-greatest large-positive-integer)
                     (fx-least large-negative-integer)))

(load "tests/tests.mit-scheme.scm")

(load "lib/srfi/276.sign-negative.scm")
(load "tests/flsign-negative.scm")
(test-flsign-negative?)

(load "lib/srfi/276.integer-exponent.scm")
(load "lib/srfi/276.new-constants.scm")
(load "tests/flinteger-exponent.scm")
(test-flinteger-exponent)

(load "tests/implementation-constants.scm")
(begin
  (test-fl-radix)
  (test-fl-precision)
  (test-fl-maximum-exponent)
  (test-fl-minimum-exponent)
  (test-fl-minimum-normalized-exponent)
  (test-fl-limit-constants)
  (test-fl-epsilon)
  (test-fl-byte-width))

(load "lib/srfi/276.flonum.scm")
(load "tests/flonum.scm")
(test-flonum)
(test-flonum-property)

(load "tests/fladjacent.scm")
(test-fladjacent)

(load "tests/flcopysign.scm")
(test-flcopysign)

(load "tests/flinteger-fraction.scm")
(test-flinteger-fraction)

(load "tests/flexponent.scm")
(test-flexponent)

(load "lib/srfi/276.serialization.scm")
(load "tests/bytevector.scm")
(test-binary64-bytevector-on-basic-numbers)
(test-binary64-bytevector-flonum-ref)

(load "tests/flnormalized-fraction-exponent.scm")
(test-flnormalized-fraction-exponent)
(load "tests/make-flonum.scm")
(test-make-flonum)

(load "tests/order.scm")
(test-flonum-order)
(test-negative-infinity-less-than-all-ordered)
(test-fl-greatest-is-greater-than-all-finite)
(test-positive-infinity-is-greater-than-all-ordered)
(test-trichotomy-of-order)
(test-weak-order)

(load "tests/total-order.scm")
(test-fl<?-implies-fltotal<?)
(test-eqv?-implies-fltotal?)
(test-trichotomy-of-total-order)
(test-weak-total-order)
(test-nans-are-ordered-beyond-finite-values)
(test-total-order-special-cases)

;;;; Property tests

(load "tests/properties.scm")
(flnormalized-fraction-exponent-and-make-flonum-are-inverses)
