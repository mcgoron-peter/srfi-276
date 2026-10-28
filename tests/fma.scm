(define (test-fl+*)
  (test-group "fl+*"
    (test-values (fl+* 0.0 0.0 0.0) '(0.0))
    (test-values (fl+* 0.0 -0.0 -0.0) '(-0.0))
    (test-values (fl+* -0.0 0.0 -0.0) '(-0.0))
    (test-values (fl+* 0.0 0.0 -0.0) '(0.0))
    (test-values (fl+* -0.0 0.0 0.0) '(0.0))
    (test-values (fl+* 2.0 4.0 1.0) '(9.0))
    (test-values (fl+* +inf.0 -inf.0 -inf.0) '(-inf.0))
    (test-assert "(fl+* +inf.0 0.0 1.0)"
      (true-and-raises 'invalid-operation
        (flnan? (fl+* +inf.0 0.0 1.0))))))
