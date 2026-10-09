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

(include "flonum.scm")
(test-flonum)
(test-flonum-property)

(include "fladjacent.scm")
(test-fladjacent)

(include "flcopysign.scm")
(test-flcopysign)

(include "flinteger-fraction.scm")
(test-flinteger-fraction)

(include "flexponent.scm")
(test-flexponent)

(include "flnormalized-fraction-exponent.scm")
(test-flnormalized-fraction-exponent)
(flnormalized-fraction-exponent-and-make-flonum-are-inverses)

(include "order.scm")
(test-flonum-order)
(test-negative-infinity-less-than-all-ordered)
(test-fl-greatest-is-greater-than-all-finite)
(test-positive-infinity-is-greater-than-all-ordered)
(test-trichotomy-of-order)
(test-weak-order)

(include "total-order.scm")
(test-fl<?-implies-fltotal<?)
(test-eqv?-implies-fltotal=?)
(test-trichotomy-of-total-order)
(test-weak-total-order)
(test-nans-are-ordered-beyond-finite-values)
(test-total-order-special-cases)

(include "flunordered.scm")
(test-nans-are-unordered)
(test-non-nans-are-ordered)

(include "fl-not-equal.scm")
(test-fl!=?)

(include "subtype-predicates.scm")
(test-flinteger?)
(test-flzero?)
(test-flpositive?)
(test-flnegative?)
(test-flodd?)
(test-fleven?)
(test-flfinite?)
(test-flinfinite?)
(test-property-nans)
(test-flnormal?)
(test-flsubnormal?)

(include "maxmin.scm")
(test-flmax)
(test-flmax-filter-nans)
(test-flmin)
(test-flmin-filter-nans)
(test-flmax-abs)
(test-flmax-abs-filter-nans)
(test-flmin-abs)
(test-flmin-abs-filter-nans)

(include "arith.scm")
(test-fl+)
(test-fl-)
(test-fl*)
(test-fl/)

(include "fma.scm")
(test-fl+*)

(include "abs.scm")
(test-flabs)
(test-flabs-sign-positive)

(include "flabsdiff.scm")
(test-flabsdiff)
(test-flabsdiff-defining-property)

(include "flposdiff.scm")
(test-flposdiff)
(test-flabsdiff-defining-property)

(include "flsgn.scm")
(test-flsgn-defining-property)

(include "flnumerator-and-fldenominator.scm")
(test-flnumerator)
(test-fldenominator)
(test-flnumerator-and-fldenominator-property)

(include "flfloor.scm")
(test-flfloor)
(test-flfloor-is-integer)
(test-flfloor-not-larger)

(include "flceiling.scm")
(test-flceiling)
(test-flceiling-is-integer)
(test-flceiling-not-smaller)

(include "fltruncate.scm")
(test-fltruncate)
(test-fltruncate-is-integer)
(test-fltruncate-closer-to-zero)

(include "flround.scm")
(test-flround)
(test-flround-is-integer)
(test-flround-property)

(load "lib/srfi/276.round-away.scm")
(include "flround-away.scm")
(test-flround-away)
(test-flround-away-is-integer)
(test-flround-away-property)

(include "fltruncate-quotient.scm")
(test-fltruncate-quotient-for-infinite-denominator)
(test-fltruncate-quotient-finite-sign)

(include "test-flremquo.scm")
(test-flremquo)
