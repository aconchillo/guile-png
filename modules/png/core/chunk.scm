;;; png-chunk.scm -- A PNG Chunk.


(define-module (png core chunk)
  #:use-module (oop goops)
  #:use-module (png core common)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 binary-ports)
  #:use-module (rnrs bytevectors)
  #:export (<png-chunk>
            png-chunk-length
            png-chunk-length-set!
            png-chunk-type
            png-chunk-type-set!
            png-chunk-type/name
            png-chunk-type/description
            png-chunk-data
            png-chunk-data-set!
            png-chunk-crc
            png-chunk-crc-set!
            png-chunk->png

            ;; Chunk type/vector converters.
            vector->chunk-type
            chunk-type->vector

            ;; Constants.
            %png-chunk-length-bytes
            %png-chunk-type-bytes
            %png-chunk-crc-bytes))


(define %png-chunk-length-bytes 4)
(define %png-chunk-type-bytes   4)
(define %png-chunk-crc-bytes    4)


(define %chunk-types
  '(
    ;; 1. Critical chunk types.
    (IHDR #vu8(73 72 68 82)   "Image header")
    (PLTE #vu8(80 76 84 69)   "Palette")
    (IDAT #vu8(73 68 65 84)   "Image data")
    (IEND #vu8(73 69 78 68)   "Image trailer")

    ;; 2. Ancillary chunk types.
    (tRNS #vu8(116 82 78 83)  "Transparency")
    (cHRM #vu8(99 72 82 77)   "Primary chromaticities and white point")
    (gAMA #vu8(103 65 77 65)  "Image gamma")
    (iCCP #vu8(105 67 67 80)  "Embedded ICC profile")
    (sBIT #vu8(115 66 73 84)  "Significant bits")
    (sRGB #vu8(115 82 71 66)  "Standard RGB color space")

    ;; 2.1. Textual information.
    (tEXT #vu8(116 69 88 116) "Textual data")
    (zTXt #vu8(122 84 88 116) "Compressed textual data")
    (iTXt #vu8(105 84 88 116) "International textual data")

    ;; 2.2. Miscellaneous information.
    (bKGD #vu8(98 75 71 68)   "Background color")
    (hIST #vu8(104 73 83 84)  "Image histogram")
    (pHYs #vu8(112 72 89 115) "Physical pixel dimensions")
    (sPLT #vu8(115 80 76 84)  "Suggested palette")

    ;; 2.3. Time stamp information.
    (tIME #vu8(116 73 77 69)  "Image last-modification time")
    ))

(define-method (vector->chunk-type (vec <bytevector>))
  "Convert a vector VEC with PNG chunk type to a PNG chunk type list.  Return
the list."
  (let loop ((types %chunk-types))
    (if (null? types)
        #f
        (if (equal? (list-ref (car types) 1) vec)
            (car types)
            (loop (cdr types))))))

(define-method (chunk-type->vector (type <symbol>))
  "Convert a PNG chunk TYPE to a vector.  Return the vector."
  (cadr (find (lambda (t)
                (equal? (car t) type))
              %chunk-types)))

  
(define-class <png-chunk> ()
  ;; A 4-byte unsigned integer giving the number of bytes in the chunk's data
  ;; field. The length counts only the data field, not itself, the chunk type
  ;; code, or the CRC.  Zero is a valid length.  The value must not exceed
  ;; (2^31)-1 bytes.
  ;;
  ;; <number>
  (length
   #:init-value   0
   #:init-keyword #:length
   #:getter       png-chunk-length
   #:setter       png-chunk-length-set!)

  ;; A 4-byte chunk type code.  For convenience in description and in
  ;; examining PNG files, type codes are restricted to consist of uppercase
  ;; and lowercase ASCII letters (A-Z and a-z, or 65-90 and 97-122 decimal).
  ;; <vector>
  (type
   #:init-thunk   (lambda () (make-bytevector 0))
   #:init-keyword #:type
   #:getter       png-chunk-type
   #:setter       png-chunk-type-set!)

  ;; The chunk data.  This part can be of zero length.
  ;;
  ;; <vector>
  (data
   #:init-thunk   (lambda () (make-bytevector 0))
   #:init-keyword #:data
   #:getter       png-chunk-data
   #:setter       png-chunk-data-set!)

  ;; 4-byte CRC Cyclic Redundancy Check) calculated on the preceding bytes in
  ;; the chunk, including the chunk type code and chunk data fields, but not
  ;; including the length field.  The CRC is always present, even for chunks
  ;; containing no data.
  ;;
  ;; <vector>
  (crc
   #:init-thunk   (lambda () (make-bytevector 0))
   #:init-keyword #:crc
   #:getter       png-chunk-crc
   #:setter       png-chunk-crc-set!)

  #:metaclass <redefinable-class>)



(define-method (%display (chunk <png-chunk>) (port <port>))
  (let ((type (vector->chunk-type (png-chunk-type chunk))))
    (format port "#<png-chunk:~a ~a ~a>"
            (list-ref type 0)
            (list-ref type 2)
            (object-address/hex-string chunk))))

(define-method (display (chunk <png-chunk>) (port <port>))
  (%display chunk port))

(define-method (write (chunk <png-chunk>) (port <port>))
  (%display chunk port))



(define-method (png-chunk-type/name (chunk <png-chunk>))
  "Get the name of the PNG CHUNK type.  Return the type name as a string."
  (let ((type (vector->chunk-type (png-chunk-type chunk))))
    (and type
         (list-ref type 0))))

(define-method (png-chunk-type/description (chunk <png-chunk>))
  "Get the description of the PNG CHUNK type.  Return the description as a
string."
  (let ((type (vector->chunk-type (png-chunk-type chunk))))
    (and type
         (list-ref type 2))))



(define-method (png-chunk->png (chunk <png-chunk>) (port <output-port>))
  "Print a PNG CHUNK to a binary PORT."
  (put-bytevector port (int32->bytevector (png-chunk-length chunk)))
  (put-bytevector port (png-chunk-type chunk))
  (put-bytevector port (png-chunk-data chunk))
  (put-bytevector port (png-chunk-crc chunk)))


;;; png-chunk.scm ends here.
