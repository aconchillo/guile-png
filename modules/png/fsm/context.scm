;;; Generated by Guile-SMC 0.5.2
;;; <https://github.com/artyom-poptsov/guile-smc>


(define-module
  (png fsm context)
  #:use-module
  (smc core common)
  #:use-module
  (smc context context)
  #:use-module
  (smc context char-context)
  #:use-module
  (smc core config)
  #:use-module
  (smc core log)
  #:re-export
  (guard:eof-object?
    guard:newline?
    guard:ascii?
    guard:hex-digit?
    guard:symbol?
    guard:punctuation?
    guard:blank?
    guard:whitespace?
    guard:printing?
    guard:graphic?
    guard:letter+digit?
    guard:digit?
    guard:upper-case?
    guard:lower-case?
    guard:letter?
    guard:del?
    guard:tilde?
    guard:right-curly-bracket?
    guard:vertical-line?
    guard:left-curly-bracket?
    guard:letter-z?
    guard:letter-y?
    guard:letter-x?
    guard:letter-w?
    guard:letter-v?
    guard:letter-u?
    guard:letter-t?
    guard:letter-s?
    guard:letter-r?
    guard:letter-q?
    guard:letter-p?
    guard:letter-o?
    guard:letter-n?
    guard:letter-m?
    guard:letter-l?
    guard:letter-k?
    guard:letter-j?
    guard:letter-i?
    guard:letter-h?
    guard:letter-g?
    guard:letter-f?
    guard:letter-e?
    guard:letter-d?
    guard:letter-c?
    guard:letter-b?
    guard:letter-a?
    guard:grave-accent?
    guard:low-line?
    guard:circumflex-accent?
    guard:right-square-bracket?
    guard:reverse-solidus?
    guard:left-square-bracket?
    guard:letter-Z?
    guard:letter-Y?
    guard:letter-X?
    guard:letter-W?
    guard:letter-V?
    guard:letter-U?
    guard:letter-T?
    guard:letter-S?
    guard:letter-R?
    guard:letter-Q?
    guard:letter-P?
    guard:letter-O?
    guard:letter-N?
    guard:letter-M?
    guard:letter-L?
    guard:letter-K?
    guard:letter-J?
    guard:letter-I?
    guard:letter-H?
    guard:letter-G?
    guard:letter-F?
    guard:letter-E?
    guard:letter-D?
    guard:letter-C?
    guard:letter-B?
    guard:letter-A?
    guard:at-symbol?
    guard:question-mark?
    guard:more-than-sign?
    guard:equals-sign?
    guard:less-than-sign?
    guard:semicolon?
    guard:colon?
    guard:digit-nine?
    guard:digit-eight?
    guard:digit-seven?
    guard:digit-six?
    guard:digit-five?
    guard:digit-four?
    guard:digit-three?
    guard:digit-two?
    guard:digit-one?
    guard:digit-zero?
    guard:solidus?
    guard:full-stop?
    guard:hyphen-minus?
    guard:comma?
    guard:plus-sign?
    guard:asterisk?
    guard:right-parenthesis?
    guard:left-parenthesis?
    guard:single-quote?
    guard:ampersand?
    guard:percent-sign?
    guard:dollar-sign?
    guard:number-sign?
    guard:double-quote?
    guard:exclamation-mark?
    guard:space?
    guard:us?
    guard:rs?
    guard:gs?
    guard:fs?
    guard:esc?
    guard:sub?
    guard:em?
    guard:can?
    guard:etb?
    guard:syn?
    guard:nak?
    guard:dc4?
    guard:dc3?
    guard:dc2?
    guard:dc1?
    guard:dle?
    guard:si?
    guard:so?
    guard:cr?
    guard:ff?
    guard:vt?
    guard:lf?
    guard:tab?
    guard:bs?
    guard:bel?
    guard:ack?
    guard:enq?
    guard:eot?
    guard:etx?
    guard:stx?
    guard:soh?
    guard:nul?
    <char-context>
    char-context-port
    char-context-counter
    char-context-row
    char-context-col
    char-context-update-counters!
    event-source
    action:syntax-error
    context-log-error
    context-log-warning
    context-log-info
    context-log-debug
    make-char-guard
    make-charset-guard
    <context>
    context?
    context-debug-mode?
    context-debug-mode-set!
    context-stanza
    context-stanza-set!
    context-stanza-add!
    context-stanza-clear!
    context-buffer
    context-buffer-set!
    context-buffer-add!
    context-buffer-clear!
    context-clear!
    #{guard:#t}#
    action:no-op
    action:store
    action:clear-buffer
    action:update-stanza
    <precise-logger>
    precise-logger?
    <system-log>
    system-log?
    <null-log>
    null-log?
    <precise-port-log>
    precise-port-log?
    <stderr-log>
    stderr-log?
    smc-log-init!
    smc-log
    log-add-handler!
    log-remove-handler!
    log-clear-handlers!
    log-error
    log-warning
    log-info
    log-debug
    log-use-stderr!
    %precise-log-formatter
    %precise-log-helper
    define-method-with-docs
    object-address/hex-string
    safe-module-ref
    safe-module-list-ref
    %logger-binary))
