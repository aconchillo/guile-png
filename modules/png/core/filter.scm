;;; filter.scm -- PNG filters.

;; Copyright (C) 2022 Artyom V. Poptsov <poptsov.artyom@gmail.com>
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; The program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with the program.  If not, see <http://www.gnu.org/licenses/>.


;;; Commentary:

;; This module contains implementation of PNG filters as described in RFC
;; 2083, section 6 ("Filter Algorithms"). [1]
;;
;; [1] https://www.rfc-editor.org/rfc/rfc2083#section-6


;;; Code:

(define-module (png core filter)
  #:use-module (oop goops)
  #:use-module (rnrs bytevectors)
  #:use-module (png core common)
  #:export (<png-filter>
            <png-filter:none>
            <png-filter:sub>
            <png-filter:paeth>
            <png-filter:up>
            <png-filter:average>

            png-filter-remove!

            paeth-predictor))


;; This class represents a PNG filter as described in RFC 2083.
(define-class <png-filter> ()
  ;; The length of the scanline of a PNG image in bytes.  This should be
  ;; calculated as follows:
  ;;
  ;;   scanline-length = image-width * bits-per-pixel
  ;;
  ;; <number>
  (scanline-length
   #:init-keyword #:scanline-length
   #:getter       png-filter-scanline-length)

  ;; The number of bytes per image pixel.
  ;;
  ;; <number>
  (bytes-per-pixel
   #:init-keyword #:bytes-per-pixel
   #:getter       png-filter-bytes-per-pixel))



(define-method (%display (filter <png-filter>) (port <port>))
  (format port
          "#<png-filter scanline-length: ~ab bytes-per-pixel: ~ab ~a>"
          (png-filter-scanline-length filter)
          (png-filter-bytes-per-pixel filter)
          (object-address/hex-string filter)))

(define-method (display (filter <png-filter>) (port <port>))
  (%display filter port))

(define-method (write (filter <png-filter>) (port <port>))
  (%display filter port))



(define-class <png-filter:none> (<png-filter>))

(define-method (%display (filter <png-filter:none>) (port <port>))
  (format port
          "#<png-filter:none scanline-length: ~ab bytes-per-pixel: ~ab ~a>"
          (png-filter-scanline-length filter)
          (png-filter-bytes-per-pixel filter)
          (object-address/hex-string filter)))

(define-method (png-filter-remove! (filter         <png-filter:none>)
                                   (input          <bytevector>)
                                   (output         <bytevector>)
                                   (scanline-index <number>))
  "Remove the 'None' filter (RFC 2083, 6.2) from a scanline with the specified
SCANLINE-INDEX."
  (let* ((scanline-length (png-filter-scanline-length filter))
         (input-scanline-begin  (+ (* scanline-index (+ scanline-length 1)) 1))
         (output-scanline-begin (* scanline-index scanline-length)))
    (bytevector-copy! input
                      input-scanline-begin
                      output
                      output-scanline-begin
                      scanline-length)))


(define-class <png-filter:sub> (<png-filter>))

(define-method (%display (filter <png-filter:sub>) (port <port>))
  (format port
          "#<png-filter:sub scanline-length: ~ab bytes-per-pixel: ~ab ~a>"
          (png-filter-scanline-length filter)
          (png-filter-bytes-per-pixel filter)
          (object-address/hex-string filter)))

(define-method (png-filter-remove! (filter         <png-filter:sub>)
                                   (input          <bytevector>)
                                   (output         <bytevector>)
                                   (scanline-index <number>))
  "Remove the 'Sub' filter (RFC 2083, 6.3) from a scanline with the specified
SCANLINE-INDEX."
  (let* ((scanline-length       (png-filter-scanline-length filter))
         (bytes-per-pixel       (png-filter-bytes-per-pixel filter))
         (input-scanline-begin  (+ (* scanline-index (+ scanline-length 1)) 1))
         (output-scanline-begin (* scanline-index scanline-length)))

    (let loop ((index 0))
      (unless (= index scanline-length)
        (let* ((left  (if (< (- index bytes-per-pixel) 0)
                          0
                          (bytevector-u8-ref output
                                             (+ output-scanline-begin
                                                (- index bytes-per-pixel)))))
               (sub-x (bytevector-u8-ref input
                                         (+ input-scanline-begin index))))
          (bytevector-u8-set! output
                              (+ output-scanline-begin index)
                              (modulo (+ sub-x left)
                                      256)))
        (loop (+ index 1))))))



(define-class <png-filter:up> (<png-filter>))

(define-method (%display (filter <png-filter:up>) (port <port>))
  (format port
          "#<png-filter:up scanline-length: ~ab bytes-per-pixel: ~ab ~a>"
          (png-filter-scanline-length filter)
          (png-filter-bytes-per-pixel filter)
          (object-address/hex-string filter)))

(define-method (png-filter-remove! (filter         <png-filter:up>)
                                   (input          <bytevector>)
                                   (output         <bytevector>)
                                   (scanline-index <number>))
  "Remove the 'Up' filter (RFC 2083, 6.4) from a scanline with the specified
SCANLINE-INDEX."
  (let* ((scanline-length        (png-filter-scanline-length filter))
         (input-scanline-begin    (+ (* scanline-index (+ scanline-length 1)) 1))
         (output-scanline-begin   (* scanline-index scanline-length))
         (previous-scanline-begin (* (- scanline-index 1) scanline-length)))
    (let loop ((index 0))
      (unless (= index scanline-length)
        (let* ((raw   (bytevector-u8-ref input
                                         (+ input-scanline-begin index)))
               (prior (if (zero? scanline-index)
                          0
                          (bytevector-u8-ref output
                                             (+ previous-scanline-begin
                                                index)))))

          (bytevector-u8-set! output
                              (+ output-scanline-begin index)
                              (modulo (+ raw prior)
                                      256)))
        (loop (+ index 1))))))



(define-class <png-filter:average> (<png-filter>))

(define-method (%display (filter <png-filter:average>) (port <port>))
  (format port
          "#<png-filter:average scanline-length: ~ab bytes-per-pixel: ~ab ~a>"
          (png-filter-scanline-length filter)
          (png-filter-bytes-per-pixel filter)
          (object-address/hex-string filter)))

(define-method (png-filter-remove! (filter         <png-filter:average>)
                                   (input          <bytevector>)
                                   (output         <bytevector>)
                                   (scanline-index <number>))
  "Remove the 'Average' filter (RFC 2083, 6.5) from a scanline with the specified
SCANLINE-INDEX."
  (let* ((scanline-length        (png-filter-scanline-length filter))
         (bytes-per-pixel         (png-filter-bytes-per-pixel filter))
         (input-scanline-begin    (+ (* scanline-index (+ scanline-length 1)) 1))
         (output-scanline-begin   (* scanline-index scanline-length)))
    (let loop ((index 0))
      (unless (= index scanline-length)
        (let* ((average (bytevector-u8-ref input
                                           (+ input-scanline-begin index)))
               (prior-x (if (zero? scanline-index)
                            0
                            (bytevector-u8-ref output
                                               (+ (- output-scanline-begin scanline-length)
                                                  index))))
               (raw     (if (< (- index bytes-per-pixel) 0)
                            0
                            (bytevector-u8-ref output
                                               (+ output-scanline-begin
                                                  (- index bytes-per-pixel))))))
          (bytevector-u8-set! output
                              (+ output-scanline-begin index)
                              (modulo (+ average (floor (/ (+ raw prior-x) 2)))
                                      256)))
        (loop (+ index 1))))))



(define-class <png-filter:paeth> (<png-filter>))

(define-method (%display (filter <png-filter:paeth>) (port <port>))
  (format port
          "#<png-filter:paeth scanline-length: ~ab bytes-per-pixel: ~ab ~a>"
          (png-filter-scanline-length filter)
          (png-filter-bytes-per-pixel filter)
          (object-address/hex-string filter)))

(define-method (paeth-predictor (left <number>)
                                (above <number>)
                                (upper-left <number>))
  "Paeth predictor that is implemented based on the description in RFC 2083.
The original algorithm developed by Alan W. Paeth."
  (let* ((p            (+ left (- above upper-left)))
         (p-left       (abs (- p left)))
         (p-above      (abs (- p above)))
         (p-upper-left (abs (- p upper-left))))
    (cond
     ((and (<= p-left p-above) (<= p-left p-upper-left))
      left)
     ((<= p-above p-upper-left)
      above)
     (else
      upper-left))))

(define-method (png-filter-apply! (filter         <png-filter:paeth>)
                                  (input          <bytevector>)
                                  (output         <bytevector>)
                                  (scanline-index <number>))
  "Remove the 'Paeth' filter (RFC 2083, 6.6) from a scanline with the specified
SCANLINE-INDEX."
  (let* ((scanline-length         (png-filter-scanline-length filter))
         (bytes-per-pixel         (png-filter-bytes-per-pixel filter))
         (input-scanline-begin    (* scanline-index (+ scanline-length 1)))
         (output-scanline-begin   (* scanline-index scanline-length))
         (previous-scanline-begin (* (- scanline-index 1) scanline-length)))

    (let loop ((index 0))
      (unless (= index scanline-length)
        (let* ((absolute-index (+ input-scanline-begin index))
               (left          (if (zero? index)
                                  0
                                  (bytevector-u8-ref input
                                                     (+ input-scanline-begin
                                                        (- index 1)))))
               (above         (if (zero? scanline-index)
                                  0
                                  (bytevector-u8-ref output
                                                     (+ previous-scanline-begin
                                                        index))))
               (upper-left    (if (or (zero? scanline-index) (zero? index))
                                  0
                                  (bytevector-u8-ref output
                                                     (+ previous-scanline-begin
                                                        (- index 1)))))
               (raw          (bytevector-u8-ref input absolute-index)))
          (bytevector-u8-set! output
                              (+ output-scanline-begin index)
                              (modulo (- raw
                                         (paeth-predictor left above upper-left))
                                      256)))
        (loop (+ index 1))))))

(define-method (png-filter-remove! (filter         <png-filter:paeth>)
                                   (input          <bytevector>)
                                   (output         <bytevector>)
                                   (scanline-index <number>))
  (let* ((scanline-length         (png-filter-scanline-length filter))
         (bytes-per-pixel         (png-filter-bytes-per-pixel filter))
         (input-scanline-begin    (+ (* scanline-index (+ scanline-length 1)) 1))
         (output-scanline-begin   (* scanline-index scanline-length))
         (previous-scanline-begin (* (- scanline-index 1) scanline-length)))

    (let loop ((index 0))
      (unless (= index scanline-length)
        (let* ((left          (if (< (- index bytes-per-pixel) 0)
                                  0
                                  (bytevector-u8-ref output
                                                     (+ output-scanline-begin
                                                        (- index bytes-per-pixel)))))
               (above         (if (zero? scanline-index)
                                  0
                                  (bytevector-u8-ref output
                                                     (+ previous-scanline-begin
                                                        index))))
               (upper-left    (if (< (- index bytes-per-pixel) 0)
                                  0
                                  (bytevector-u8-ref output
                                                     (+ previous-scanline-begin
                                                        (- index bytes-per-pixel)))))
               (raw          (bytevector-u8-ref input (+ input-scanline-begin
                                                         index)))
               (paeth        (paeth-predictor left above upper-left)))

          (bytevector-u8-set! output
                              (+ output-scanline-begin index)
                              (modulo (+ raw paeth)
                                      256)))
        (loop (+ index 1))))))

;;; filter.scm ends here.
