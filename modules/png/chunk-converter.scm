(define-module (png chunk-converter)
  #:use-module (oop goops)
  #:use-module (png core chunk)
  #:use-module (png core chunk-ihdr)
  #:use-module (png core chunk-plte)
  #:use-module (png core chunk-iend)
  #:use-module (png core chunk-chrm)
  #:use-module (png core chunk-ztxt)
  #:use-module (png core chunk-time)
  #:use-module (png core chunk-iccp)
  #:use-module (png core chunk-phys)
  #:export (png-chunk->png-chunk:IHDR
            png-chunk->png-chunk:PLTE
            png-chunk->png-chunk:IEND
            png-chunk->png-chunk:cHRM
            png-chunk->png-chunk:zTXt
            png-chunk->png-chunk:tIME
            png-chunk->png-chunk:iCCP
            png-chunk->typed-chunk))

(define-method (png-chunk->png-chunk:IHDR (chunk <png-chunk>))
  (data->png-chunk:IHDR (png-chunk-data   chunk)
                        (png-chunk-type   chunk)
                        (png-chunk-length chunk)
                        (png-chunk-crc    chunk)))

(define-method (png-chunk->png-chunk:PLTE (chunk <png-chunk>))
  (data->png-chunk:PLTE (png-chunk-data   chunk)
                        (png-chunk-type   chunk)
                        (png-chunk-length chunk)
                        (png-chunk-crc    chunk)))

(define-method (png-chunk->png-chunk:IEND (chunk <png-chunk>))
  (data->png-chunk:IEND (png-chunk-data   chunk)
                        (png-chunk-type   chunk)
                        (png-chunk-length chunk)
                        (png-chunk-crc    chunk)))

(define-method (png-chunk->png-chunk:cHRM (chunk <png-chunk>))
  (data->png-chunk:cHRM (png-chunk-data   chunk)
                        (png-chunk-type   chunk)
                        (png-chunk-length chunk)
                        (png-chunk-crc    chunk)))

(define-method (png-chunk->png-chunk:zTXt (chunk <png-chunk>))
  (data->png-chunk:zTXt (png-chunk-data   chunk)
                        (png-chunk-type   chunk)
                        (png-chunk-length chunk)
                        (png-chunk-crc    chunk)))

(define-method (png-chunk->png-chunk:tIME (chunk <png-chunk>))
  (data->png-chunk:tIME (png-chunk-data   chunk)
                        (png-chunk-type   chunk)
                        (png-chunk-length chunk)
                        (png-chunk-crc    chunk)))

(define-method (png-chunk->png-chunk:iCCP (chunk <png-chunk>))
  (data->png-chunk:iCCP (png-chunk-data   chunk)
                        (png-chunk-type   chunk)
                        (png-chunk-length chunk)
                        (png-chunk-crc    chunk)))

(define-method (png-chunk->png-chunk:pHYs (chunk <png-chunk>))
  (data->png-chunk:pHYs (png-chunk-data   chunk)
                        (png-chunk-type   chunk)
                        (png-chunk-length chunk)
                        (png-chunk-crc    chunk)))


(define %converters-to-typed
  `((IHDR                  . ,png-chunk->png-chunk:IHDR)
    (PLTE                  . ,png-chunk->png-chunk:PLTE)
    (IEND                  . ,png-chunk->png-chunk:IEND)
    (cHRM                  . ,png-chunk->png-chunk:cHRM)
    (zTXt                  . ,png-chunk->png-chunk:zTXt)
    (tIME                  . ,png-chunk->png-chunk:tIME)
    (iCCP                  . ,png-chunk->png-chunk:iCCP)
    (pHYs                  . ,png-chunk->png-chunk:pHYs)))

(define-method (png-chunk->typed-chunk (chunk <png-chunk>))
  (let ((type (png-chunk-type/name chunk)))
    (if type
        (let ((converter (assoc-ref %converters-to-typed type)))
          (if converter
              (converter chunk)
              chunk))
        (error "Unknown chunk type" type chunk))))
