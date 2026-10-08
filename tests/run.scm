(import (scheme base) (srfi 276) (srfi 64) (srfi 194) (srfi 252))

(include "tests.srfi-64.scm")
(include "random-flonum.scm")
(include "flsign-negative.scm")
(test-flsign-negative?)
