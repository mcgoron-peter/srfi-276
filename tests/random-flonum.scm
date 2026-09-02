;;;; NOTE: SRFI 26 specific.

(define (random-flonum)
  (do ((bv (make-bytevector fl-byte-width))
       (i 0 (+ i 1)))
      ((= i fl-byte-width)
       (bytevector-flonum-native-ref bv 0))
    (bytevector-u8-set! bv i (random-integer 256))))

(define (make-random-flonum-generator)
  (let ((fixed '(0.0 -0.0 1.0 -1.0 +inf.0 -inf.0 +nan.0 -nan.0)))
    (lambda ()
      (if (null? fixed)
	  (random-flonum)
	  (let ((x (car fixed)))
	    (set! fixed (cdr fixed))
	    x)))))

(define (make-random-finite-flonum-generator)
  (gfilter flfinite? (make-random-flonum-generator)))

(define (make-random-ordered-flonum-generator)
  (gremove flnan? (make-random-flonum-generator)))

(define (random-nan)
  (cond-expand
    ((library (srfi 208))
     (let ((payload (+ 1 
		       (random-integer #x7FFFFFFFFFF)))
	   (sign? (zero? (random-integer 2)))
	   (quiet? (zero? (random-integer 2))))
       (make-nan sign? quiet? payload (flonum 0.0))))
    (else +nan.0)))













