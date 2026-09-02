(define (flnormalized-fraction-exponent-and-make-flonum-are-inverses)
  (test-group "flnormalized-fraction-exponent and make-flonum are inverses"
    (test-property
     (lambda (fl)
       (let-values (((fr e) (flnormalized-fraction-exponent fl)))
	 (if (flnan? fl)
	     (flnan? (make-flonum fr e))
	     (equal? fl (make-flonum fr e)))))
     (list (make-random-flonum-generator)))))
