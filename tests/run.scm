(import (scheme base) (srfi 276) (srfi 64) (srfi 194) (srfi 252) (srfi 158))

(include "tests.srfi-64.scm")
(include "random-flonum.scm")

(include "flsign-negative.scm")
(test-flsign-negative?)

(include "flinteger-exponent.scm")
(test-flinteger-exponent)

(include "implementation-constants.scm")
(begin
  (test-fl-radix)
  (test-fl-precision)
  (test-fl-maximum-exponent)
  (test-fl-minimum-exponent)
  (test-fl-minimum-normalized-exponent)
  (test-fl-limit-constants)
  (test-fl-epsilon)
  (test-fl-byte-width))

(include "bytevector.scm")
(test-binary64-bytevector-on-basic-numbers)
(test-binary64-bytevector-flonum-ref)
(test-bytevector-flonum-native-reverse)
(test-bytevector-flonum-reverse)

