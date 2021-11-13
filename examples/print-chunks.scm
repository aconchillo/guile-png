#!/usr/bin/guile \
-L modules -e main -s
!#

(use-modules (oop goops)
             (smc core log)
             (png image)
             (png))

(define (main args)
  (let ((image (png->scm (current-input-port)
                         #:debug-mode? #t
                         #:raw?        #f)))
    (display "PNG chunks:\n")
    (for-each (lambda (chunk)
                (format #t "  ~a~%" chunk))
              (png-image-chunks image))))
