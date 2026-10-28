;; Enable exception handling
(flo:clear-exceptions! (flo:supported-exceptions))
(load "../mit-scheme-lib/srfi/276/exception.sld")
(load "../lib/srfi/276.sld")
,(import (srfi 27) (srfi 276) (srfi 158) (srfi 276 exception))
(load "tests.mit-scheme.scm")
(define skipping? #f)
(load "run.body.scm")
