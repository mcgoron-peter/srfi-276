;; Enable exception handling
(flo:clear-exceptions! (flo:supported-exceptions))
(load "../mit-scheme-lib/srfi/276/exception.sld")
,(import (srfi 276 exception))
(load "../lib/srfi/276.sld")
,(import (srfi 27) (srfi 276) (srfi 158))

(load "tests.mit-scheme.scm")
#|
(define skipping? #f)
(test-verbose? #f)
(load "run.body.scm")

(display "Total tests passed: ")
(display tests-passed)
(newline)

(display "Total tests failed: ")
(display tests-failed)
(newline)

(display "Total tests: ")
(display tests-run)
(newline)

(exit (if (zero? tests-failed)
        0
        1))
|#
