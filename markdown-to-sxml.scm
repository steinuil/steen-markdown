#!/usr/bin/env chibi-scheme
(import (scheme small)
        (scheme process-context)
        (steen markdown)
        (chibi sxml))

(if (or (eq? (cdr (command-line)) '()) (eq? (cddr (command-line)) '()))
  (display (string-append "Usage: "
                          (car (command-line))
                          " <input.md> <output.scm>\n"))
  (call-with-output-file (caddr (command-line))
    (lambda (output)
      (call-with-input-file (cadr (command-line))
        (lambda (input)
          (display (sxml->xml (markdown->sxml input)) output))))))
