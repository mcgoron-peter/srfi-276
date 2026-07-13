(define-library (srfi NNN)
  (import (scheme base)
          (only (mit legacy runtime)
                flo:rounding-mode flo:flonum flo:flonum?
                flo:adjacent flo:ldexp
                flo:safe= flo:safe<
                flo:safe<= flo:safe> flo:safe>=
                flo:unordered? flo:zero? flo:positive? flo:negative?
                flo:normal? flo:subnormal?
                flo:finite? flo:infinite?
                flo:nan?
                flo:fast-fma?
                flo:+ flo:- flo:* flo:/ flo:+*
                flo:abs flo:copysign
                flo:floor flo:ceiling flo:round flo:truncate
                flo:exp flo:exp2 flo:expm1
                flo:log flo:logp1
                flo:log2 flo:log10
                flo:sin flo:cos flo:tan
                flo:asin flo:acos flo:atan flo:atan2
                flo:sinh flo:cosh flo:tanh
                flo:asinh flo:acosh flo:atanh
                flo:sqrt flo:cbrt
                flo:hypot
                flo:largest-positive-normal
                flo:smallest-positive-subnormal
                flo:error-bound
                flo:logb flo:sign-negative?
                flo:max flo:min
                host-big-endian?))
  (export :rounding-mode :features :byte-width
          :bytevector-flonum-ref
          :integer-fraction :exponent :integer-exponent
          :normalized-fraction-exponent :sign-bit
          :<? :>? :<=? :>=? :=?
          :+ :- :* :/ :+*
          (rename flo:flonum? :flonum?)
          (rename flo:flonum :flonum)
          (rename flo:unordered? :unordered?)
          (rename flo:zero? :zero?)
          (rename flo:positive? :positive?)
          (rename flo:negative? :negative?)
          (rename flo:normal? :normal?)
          (rename flo:subnormal? :subnormal?)
          (rename flo:finite? :finite?)
          (rename flo:infinite? :infinite?)
          (rename flo:nan? :nan?)
          (rename flo:+* :+*)
          (rename flo:abs :abs)
          (rename flo:copysign :copysign)
          (rename flo:floor :floor)
          (rename flo:ceiling :ceiling)
          (rename flo:round :round)
          (rename flo:truncate :truncate)
          (rename flo:exp :exp)
          (rename flo:exp2 :exp2)
          (rename flo:expm1 :exp-1)
          (rename flo:sqrt :sqrt)
          (rename flo:cbrt :cbrt)
          (rename flo:hypot :hypot)
          (rename flo:expt :expt)
          (rename flo:log :log)
          (rename flo:logp1 :log+1)
          (rename flo:log2 :log2)
          (rename flo:log10 :log10)
          (rename flo:sin :sin)
          (rename flo:cos :cos)
          (rename flo:tan :tan)
          (rename flo:asin :asin)
          (rename flo:acos :acos)
          (rename flo:sinh :sinh)
          (rename flo:cosh :cosh)
          (rename flo:tanh :tanh)
          (rename flo:asinh :asinh)
          (rename flo:acosh :acosh)
          (rename flo:atanh :atanh)
          (rename flo:largest-positive-normal :greatest)
          (rename flo:smallest-positive-subnormal :least)
          (rename flo:error-bound :epsilon)
          (rename flo:nextafter :adjacent)
          (rename flo:ldexp :make-flonum)
          (rename flo:logb :exponent)
          :rsqrt
          :absdiff :posdiff :sgn :numerator :denominator
          :make-log-base :atan)
  (begin
    (define (:flonum x)
      (cond
        ((not (number? x))
         (error "expected number" x))
        ((not (real? x))
         +nan.0)
        (else (inexact x))))
    (define (:rounding-mode)
      (case (flo:rounding-mode)
        ((to-nearest) 'round-to-nearest/ties-to-even)
        ((towards-zero) 'round-towards-zero)
        ((downards) 'round-towards-negative)
        ((upwards) 'round-towards-positive)
        (else => values)))
    (define (:features)
      ;; XXX: Assumes no FTZ/DAZ.
      (if (flo:fast-fma?)
          '(ieee-754-2019 non-stop fast-fma)
          '(ieee-754-2019 non-stop)))
    (define :byte-width 8)
    (define (decode-float fl)
      ;; Returns
      ;; 
      ;; sign bit (1 or 0)
      ;; exponent (exact integer)
      ;; mantissa as bytevector (in big endian)
      (let*-values (((f e) (:normalized-fraction-exponent fl))
                    ((s) (:signbit f))
                    ((f) (flo:abs f))
                    ((bv) (make-bytevector 7 0)))
        ;; Extracting the bits of the mantissa without access to the
        ;; floating point representation.
        ;; 
        ;; f = (1 + ∑_{n=1}^53 b_n*2^n) * 2^-1 (because f ∈ [0.5, 1.0))
        ;; Then F_0 = (:* (:- f 0.5) 2.0) = ∑_{n=1}^53 b_n * 2^n
        ;; 
        ;; To extract the bits of the number, then:
        ;; 
        ;; Define F_m = (:* F_{m-1} 2.0) = ∑_{n=0}^{52-m} b_n * 2^n
        ;; If (:>=? F_m 1.0) then this bit is 1, and F_m = (:- F_m 1.0).
        ;; Otherwise the bit is 0, and do nothing.
        (letrec ((loop-bits
                  (lambda (total-bits byte-idx byte F bit)
                    (cond
                      ((fix:= total-bits 52)
                       (bytevector-u8-set! bv byte-idx byte)
                       (values s e bv))
                      ((fix:= bit 8)
                       (loop-bits total-bits
                                  (fix:+ byte-idx 1)
                                  0
                                  F
                                  0))
                      (else
                       (let* ((F (:* F 2.0)))
                         (if (flo:>= F 1.0)
                             (loop-bits (fix:+ total-bits 1)
                                        byte-idx
                                        (fix:or (fix:lsh byte 1) 1)
                                        (flo:- F 1.0))
                             (loop-bits (fix:+ total-bits 1)
                                        byte-idx
                                        (fix:lsh byte 1)
                                        F))))))))
          (loop-bits 0 0 0 F 4)))
      (define :bytevector-flonum-set!
        (case-lambda
          ((bv i fl) (:bytevector-flonum-set! bv
                                              i
                                              fl
                                              (if (host-big-endian?)
                                                  'big
                                                  'little)))
          ((bv i fl endianness)
           (unless (>= (bytevector-length bv)
                       (+ i :byte-width))
             (error "invalid arguments" bv i))
           (let*-values (((s e m) (decode-float fl))
                         ((e) (fix:+ e 1023))
                         ;; First byte is sign+part of exponent
                         ((b0) (fix:or (fix:lsh s 7)
                                       (fix:lsh e -4)))
                         ;; Second byte is rest of exponent and start of mantissa.
                         ((b1) (fix:or (fix:and e #xF)
                                       (bytevector-u8-ref m 0))))
             (case endianness
               ((big)
                (bytevector-u8-set! bv i b0)
                (bytevector-u8-set! bv (+ i 1) b1)
                (bytevector-copy! bv (+ i 2) m 1))
               ((little)
                (bytevector-u8-set! bv (+ i 7) b0)
                (bytevector-u8-set! bv (+ i 6) b1)
                (do ((i (+ i 5) (- i 1))
                     (j 1 (fix:+ j 1)))
                    ((< i 0))
                  (bytevector-u8-set! bv i (bytevector-u8-ref m j))))
               (else (error "invalid endianness" endianness)))))))
      (define :bytevector-flonum-ref
        (case-lambda
          ((bv i) (:bytevector-flonum-ref bv i (if (host-big-endian?)
                                                   'big
                                                   'little)))
          ((bv i endianness)
           (unless (>= (bytevector-length bv) (+ i :byte-width))
             (error "invalid arguments" bv i))
           (case endianness
             ((big)
              (let* ((b0 (bytevector-u8-ref bv i))
                     (b1 (bytevector-u8-ref bv (+ i 1)))
                     (s (fix:lsh b0 -7))
                     (e (fix:- (fix:or (fix:lsh (fix:and b1 #x7F) 4)
                                       (fix:lsh (fix:and b1 #xF0) -4))
                               1023)))
                (let loop ((i (+ i 1))
                           (bit 4)
                           (byte (fix:lsh (fix:and b1 #xF) 4))
                           (power -1)
                           (acc 1.0))
                  (cond
                    ((> i 8) acc)
                    ((fix:= bit 8) (loop (+ i 1) 0 byte power acc))
                    (else
                     ;; The MSB of the current byte is either 1 or 0.
                     ;; This adds b^{power} to acc, where b is 1 or 0.
                     (loop i
                           (fix:+ bit 1)
                           (fix:and (fix:lsh byte 1) #xFF)
                           (fix:+ power 1)
                           (if (fix:positive? (fix:and byte #x7F))
                               (flo:+ acc (flo:ldexp 1.0 power))
                               acc)))))))))))
      (define (make-nary ~?)
        (lambda (x y . rest)
          (let loop ((x x) (y y) (rest rest))
            (and (~? x y)
                 (or (null? rest)
                     (loop y (car rest) (cdr rest)))))))
      (define :=? (make-nary flo:safe=))
      (define :<? (make-nary flo:safe<))
      (define :>? (make-nary flo:safe>))
      (define :<=? (make-nary flo:safe<=))
      (define :>=? (make-nary flo:safe>=))
      (define :+
        (case-lambda
          (() 0)
          ((x) x)
          ((x y) (flo:+ x y))
          (lst
           ;; Neumaier summation
           (do ((sum 0.0)
                (c 0.0)
                (lst lst (cdr lst)))
               ((null? lst) (flo:+ sum c))
             (let* ((el (car lst))
                    (t (flo:+ sum el)))
               (if (flo:>= (flo:abs sum) (flo:abs el))
                   (set! c (flo:+ c
                                  (flo:- sum t)
                                  el))
                   (set! c (flo:+ c
                                  (flo:- el t)
                                  sum)))
               (set! sum t))))))
      (define :-
        (case-lambda
          (() (error "invalid number of arguments"))
          ((x) (flo:negate x))
          (args (apply :+ (car args)
                       (map flo:negate (cdr args))))))
      (define :*
        (case-lambda
          (() 1)
          ((x) x)
          (args (fold flo:* 1 args))))
      (define :/
        (case-lambda
          (() (error "invalid number of arguments"))
          ((x) (flo:/ 1.0 x))
          ((first . rest) (fold :/ first rest))))
      (define (:absdiff x y)
        (flo:abs (flo:- x y)))
      (define (:posdiff x y)
        (flo:max 0.0 (flo:- x y)))
      (define (:sgn x)
        (flo:copysign 1.0 x))
      (define (:numerator x)
        (if (flo:nan? x)
            x
            (numerator x)))
      (define (:denominator x)
        (if (flo:nan? x)
            x
            (denominator x)))
      (define (:square x)
        (flo:* x x))
      (define (:make-log-base base)
        (if (flo:>= base 1.0)
            (lambda (x) (log x base))
            (error "invalid log base" base)))
      (define :atan
        (case-lambda
          ((x) (flo:atan x))
          ((y x) (flo:atan2 y x))))
      (define (:rsqrt x) (:/ (:sqrt x)))
      (define (:signbit x)
        (if (flo:sign-negative? x)
            1
            0))
      (define :max
        (case-lambda
          (() +inf.0)
          ((first . rest) (fold flo:max first rest))))
      (define :min
        (case-lambda
          (() -inf.0)
          ((first . rest) (fold flo:max first rest))))
      (define :flonum->string number->string)
      (define :string->flonum string->number)
      (define :read-random-flonum
        (case-lambda
          ((port) (random-flonum port))
          ((port start) (:read-random-flonum port start 1.0))
          ((port start end)
           ;; XXX: Might not be that good.
           (flo:+ start (flo:* (random-flonum port)
                               (flo:- end start))))))
      ;; These procedures copied from SRFI 144 sample implementation.
      ;;; Copyright (C) William D Clinger (2016).
      ;;;
      ;;; Permission is hereby granted, free of charge, to any person
      ;;; obtaining a copy of this software and associated documentation
      ;;; files (the "Software"), to deal in the Software without
      ;;; restriction, including without limitation the rights to use,
      ;;; copy, modify, merge, publish, distribute, sublicense, and/or
      ;;; sell copies of the Software, and to permit persons to whom the
      ;;; Software is furnished to do so, subject to the following
      ;;; conditions:
      ;;;
      ;;; The above copyright notice and this permission notice shall be
      ;;; included in all copies or substantial portions of the Software.
      ;;;
      ;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
      ;;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
      ;;; OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
      ;;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
      ;;; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
      ;;; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
      ;;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
      ;;; OTHER DEALINGS IN THE SOFTWARE.
      (define (:integer-fraction x)
        (unless (:flonum? x)
          (error "invalid argument" x))
        (let ((int (flo:truncate x)))
          (values int (flo:- x int))))
      (define (:integer-exponent x)
        (exact (:exponent x)))
      (define (:normalized-fraction-exponent x)
        (define (return result1 result2)
          (cond ((flo:< result1 0.5)
                 (values (flo:* 2.0 result1) (- result2 1)))
                ((flo:>= result1 1.0)
                 (values (flo:* 0.5 result1) (+ result2 1)))
                (else
                 (values result1 result2))))
        (unless (:flonum? x)
          (error "invalid argment" x))
        (cond ((flo:nan? x)    ; unspecified for NaN
               (values x 0))
              ((flo:< x 0.0)
               (let-values ((y n) (:normalized-fraction-exponent (flo:- x)))
                 (lambda (y n)
                   (values (flo:- y) n))))
              ((flo:= x 0.0)    ; unspecified for 0.0
               (values 0.0 0))
              ((flo:infinite? x)
               (values 0.5 (+ 3 (exact (round (flo:log2 :greatest))))))
              ((flo:normalized? x)
               (let* ((result2 (exact (flo:round (flo:log2 x))))
                      (result2 (if (integer? result2)
                                   result2
                                   (round result2)))
                      (two^result2 (inexact (expt 2.0 result2))))
                 (if (flo:infinite? two^result2)
                     (let-values (((y n) (flnormalized-fraction-exponent
                                          (flo:/ x 4.0))))
                       (values y (+ n 2)))
                     (return (flo:/ x two^result2) result2))))
              (else
               (let* ((k (+ 2 precision-bits))
                      (two^k (expt 2 k)))
                 (let-values (((y n)
                               (flnormalized-fraction-exponent
                                (flo:* x (inexact two^k)))))
                   (return y (- n k)))))))
      ;;; Integer division
      (define (:quotient x y)
        (unless (and (flonum? x) (flonum? y))
          (error "invalid arguments" x y))
        (flo:truncate (flo:/ x y)))
      ;;; FIXME: should probably implement the following part of the C spec:
      ;;; "If the returned value is 0, it will have the same sign as x."
      (define (:remainder x y)
        (unless (and (flonum? x) (flonum? y))
          (error "invalid arguments" x y))
        (flo:- x (flo:* y (:quotient x y))))
      (define (:remquo x y)
        ;; NOTE: This might not follow this part of the C spec:
        ;; 
        ;; the object
        ;; pointed to by quo they store a value whose magnitude is congruent modulo 2n to the magnitude of
        ;; the integral quotient of x/y, where n is an implementation-defined integer greater than or equal to 3.
        ;; 
        (unless (and (flonum? x) (flonum? y))
          (error "invalid arguments" x y))
        (let* ((quo (flo:round (flo:/ x y)))
               (rem (flo:- x (flo:* y quo))))
          (values rem (exact quo))))
      #| Adapted from
Copyright (c) 2014 Taylor R. Campbell
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.
|#
      (define (random-flonum port)
        (letrec ((find-exponent
                  (lambda (exponent)
                    (let ((b (read-u8 port)))
                      (cond
                        ((not (fix:zero? b))
                         (handle-exponent
                          (shift-significand b)))
                        (else
                         (let (exponent (fix:- exponent 8))
                           (if (fix:<= exponent -1074)
                               0.0
                               (skip-zeros exponent))))))))
                 (shift-significand
                  (lambda (b)
                    (let ((lead-zeroes (fix:- (first-set-bit b) 8)))
                      (if (fix:zero? lead-zeroes)
                          b
                          (fix:or (fix:lsh b lead-zeroes)
                                  (fix:and (read-u8 port)
                                           (fix:- (fix:lsh 1 lead-zeroes)
                                                  1)))))))
                 (handle-exponent
                  (lambda (leading-byte)
                    (do ((i 1 (fix:+ i 1))
                         (num leading-byte
                              (+ (read-u8 port)
                                 (shift-left num 8))))
                        ((fix:> i 8)
                         (flo:ldexp (:flonum (bitwise-ior num 1))
                                    exponent)))))
                 (intro
                  (lambda ()
                    (let ((v (find-exponent -64)))
                      ;; return v ∈ (0,1)
                      (if (or (flo:= v 0.0)
                              (flo:= v 1.0))
                          (intro)
                          v)))))
          (intro)))
      (define (:round/ties-to-away x)
        #|
Copied from openlibm.
Copyright (c) 2003, Steven G. Kargl
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
notice unmodified, this list of conditions, and the following
disclaimer.

2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
|#
        (cond
          ((not (flo:finite? x)) (flo:+ x x))
          ((flo:positive? x)
           (let ((t (flo:floor x)))
             (if (flo:<= (flo:- t x) -0.5)
                 (flo:+ t 1)
                 t)))
          (else
           (let ((t (flo:floor (flo:negate x))))
             (if (flo:<= (flo:- t x) -0.5)
                 (flo:+ t 1)
                 (flo:negate t))))))))
