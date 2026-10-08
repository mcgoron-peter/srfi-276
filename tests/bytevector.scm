(define (flonum->bytevector fl)
  (let ((bv (make-bytevector fl-byte-width)))
    (bytevector-flonum-set! bv 0 fl 'big)
    bv))

(define (test-binary64-bytevector-flonum-ref)
  (test-equal (bytevector-flonum-ref
               #u8(#x3F #xF0 0 0 0 0 0 0)
	       0
	       'big)
	      1.0)
  (test-equal (bytevector-flonum-ref
	       #u8(0 0 0 0 0 0 #xF0 #x3F)
	       0
	       'little)
	      1.0)
  (test-equal (bytevector-flonum-ref
	       #u8(#x3F #xF8 0 0 0 0 0 0)
	       0
	       'big)
	      1.5)
  (test-equal (bytevector-flonum-ref
	       #u8(0 0 0 0 0 0 0 0 0)
	       0
	       'big)
	      0.0)
  (test-equal (bytevector-flonum-ref
	       #u8(#x7F #xF0 0 0 0 0 0 0)
	       0
	       'big)
	       +inf.0)
  (test-equal (bytevector-flonum-ref
	       #u8(0 0 0 0 0 0 #xF0 #x7F)
	       0
	       'little)
	      +inf.0))

(define (test-binary64-bytevector-on-basic-numbers)
  (test-group "test basic numbers"
    (test-equal (flonum->bytevector 1.0)
		#u8(#x3F #xF0 0 0 0 0 0 0))
    (test-equal (flonum->bytevector 1.5)
		#u8(#x3F #xF8 0 0 0 0 0 0))
    (test-equal (flonum->bytevector 0.0)
		#u8(0 0 0 0 0 0 0 0))
    (test-equal (flonum->bytevector fl-least)
                #u8(0 0 0 0 0 0 0 1))
    (test-equal (flonum->bytevector (fl- fl-least))
		#u8(#x80 0 0 0 0 0 0 1))
    (test-equal (flonum->bytevector fl-greatest)
		#u8(#x7F #xEF #xFF #xFF #xFF #xFF #xFF #xFF))
    (test-equal (flonum->bytevector (fl- fl-greatest))
		#u8(#xFF #xEF #xFF #xFF #xFF #xFF #xFF #xFF))
    (test-equal (flonum->bytevector fl-least-normal)
		#u8(0 #x10 0 0 0 0 0 0))
    (test-equal (flonum->bytevector (fl- fl-least-normal))
		#u8(#x80 #x10 0 0 0 0 0 0))
    (test-equal (flonum->bytevector -0.0)
		#u8(#x80 0 0 0 0 0 0 0))
    (test-equal (flonum->bytevector -1.0)
		#u8(#xBF #xF0 0 0 0 0 0 0))
    (test-equal (flonum->bytevector +inf.0)
		#u8(#x7F #xF0 0 0 0 0 0 0))
    (test-equal (flonum->bytevector -inf.0)
		#u8(#xFF #xF0 0 0 0 0 0 0))))

(define (test-bytevector-flonum-native-reverse)
  (test-group "bytevector-flonum-native-set! and \
               bytevector-flonum-native-ref are inverses"
    (test-property
     (lambda (len flonum)
       (let ((bv (make-bytevector (* len fl-byte-width)))
             (i (* fl-byte-width (random-integer len))))
         (bytevector-flonum-native-set! bv i flonum)
         (eqv? (bytevector-flonum-native-ref bv i) flonum)))
     (list (lambda () (+ 1 (random-integer 20)))
           (make-random-flonum-generator)))))

(define (test-bytevector-flonum-reverse)
  (test-group "bytevector-flonum-set! and \
               bytevector-flonum-ref are inverses"
    (test-property
     (lambda (len flonum endianness)
       (let* ((bytes (* len fl-byte-width))
              (bv (make-bytevector bytes))
              (i (random-integer (- bytes fl-byte-width))))
         (bytevector-flonum-set! bv i flonum endianness)
         (eqv? (bytevector-flonum-ref bv i endianness)
               flonum)))
     (list (lambda () (+ 1 (random-integer 100)))
           (make-random-flonum-generator)
           (gmap (lambda (bool)
                   (if bool 'little 'big))
                 (boolean-generator))
           ))))
