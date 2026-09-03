(define (fl!=? x y . args)
  (let loop ((x x) (y y) (args args))
    (cond
      ((flunordered? x y) #f)
      ((fl=? x y)
       (and (pair? args)
	    (loop y (car args) (cdr args))))
      (else #t))))
