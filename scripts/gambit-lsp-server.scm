#!/usr/bin/env gsi-script
;; -*- Scheme -*-

(import (codeberg.org/rgherdt/scheme-lsp-server lsp-server)
        (codeberg.org/rgherdt/scheme-lsp-server lsp-server private util))

(cond-expand
 (guile (import (except (scheme base)
                        assoc
                        cond-expand
                        member)
                (srfi srfi-18)
                (srfi srfi-28)
                (lsp-server private guile)))
 ((or chicken gambit)
  (import          (scheme char) ;; string-downcase
          (scheme process-context)
          (srfi 28))))

(cond-expand (chicken (import (lsp-server chicken)
                              (scheme base)
                              (srfi 18)))
             (gambit (import (gambit)
                             (codeberg.org/rgherdt/scheme-lsp-server lsp-server private gambit)
                             (only (srfi 1) any)))
             (guile (import (only (srfi srfi-1) any)))
             (else (import (only (srfi 1) any))))

(define implementation-name
  (cond-expand
   (chicken "CHICKEN")
   (gambit "Gambit")
   (guile "Guile")
   (else (error "Your Scheme implementation is not supported (yet)."))))

(define (print-usage)
  (define program-name
    (string-append (string-downcase implementation-name)
                   "-lsp-server"))

  (display (string-append "usage: "
                          program-name
                          " [--log-level <log-level>] [--listen <port-num>] [--version]."))
  (newline)
  (display (string-append "Example: " program-name " --log-level debug"))
  (newline)
  (display "Arguments: ")
  (newline)
  (display "    --log-level <level>: one of [error, warning, info, debug]. Default: error.")
  (newline)
  (display "    --listen <port-num>: port to listen to and spawn repl upon connection.")
  (newline)
  (display "    --tcp <port-num>: listen on tcp port <port-num> instead of stdio.")
  (newline)
  (display "    --help (or -h):    display this help and exit.")
  (newline)
  (display "    --version (or -v): display version information and exit.")
  (newline))

(define (print-version)
  (display (string-append implementation-name " LSP Server"))
  (newline)
  (display (string-append "Version " lsp-server-version))
  (newline)
  (display "Copyright (C) 2022 Ricardo Gabriel Herdt")
  (newline))

(define (valid-log-level? str)
  (any (lambda (log-level)
         (string=? log-level str))
       '("error" "warning" "info" "debug")))


(define (process-args arguments)
  (let loop ((args arguments)
             (options '()))
    (cond ((null? args)
           options)
          ((or (member "-v" args)
               (member "--version" args))
           (print-version)
           (exit))
          ((or (member "-h" args)
               (member "--help" args))
           (print-usage)
           (exit))
          ((and (>= (length args) 2)
                (string=? (car args) "--log-level")
                (valid-log-level? (cadr args)))
           (loop (cddr args)
                 (cons `(log-level . ,(string->symbol (cadr args)))
                       options)))
          ((and (>= (length args) 2)
                (string=? (car args) "--listen")
                (string->number (cadr args)))
           => (lambda (port-num)
                (loop (cddr args)
                      (cons `(listen . ,port-num) options))))
          ((and (>= (length args) 2)
                (string=? (car args) "--tcp")
                (string->number (cadr args)))
           => (lambda (port-num)
                (loop (cddr args)
                      (cons `(tcp . ,port-num) options))))
          (else (print-usage)
                (exit)))))

(define (main . args)
  (let* ((options (process-args args))
         (log-level (let ((log-level-option (assoc 'log-level options)))
                      (if log-level-option
                          (cdr log-level-option)
                          'error)))
         (repl-port-num
          (let ((listen-option (assoc 'listen options)))
            (if listen-option
                (cdr listen-option)
                #f)))
         (tcp-port-num
          (let ((tcp-option (assoc 'tcp options)))
            (if tcp-option
                (cdr tcp-option)
                #f))))


    (when repl-port-num
      (thread-start!
       (make-thread
        (lambda () (spawn-repl-server repl-port-num)))))

    (parameterize ((lsp-server-log-level log-level))
      (if tcp-port-num
          (lsp-server-start/tcp tcp-port-num)
          (lsp-server-start/stdio)))))

