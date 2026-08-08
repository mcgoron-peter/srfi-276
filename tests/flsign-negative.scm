(define (test-flsign-negative?)
  (test-group "flsign-negative?"
    (test-values (flsign-negative? -1.0) '(#t))
    (test-values (flsign-negative? 1.0) '(#f))
    (test-values (flsign-negative? 0.0) '(#f))
    (test-values (flsign-negative? -0.0) '(#t))
    (test-values (flsign-negative? +inf.0) '(#f))
    (test-values (flsign-negative? -inf.0) '(#t))
    (test-values (boolean? (flsign-negative? +nan.0)) '(#t))))
