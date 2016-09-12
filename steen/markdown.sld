(define-library
  (steen markdown)
  (import (scheme base))
  (export markdown->sxml)
  (begin
    (define-syntax scone
      (syntax-rules ()
        ((_ ls new) (append ls (list new)))))

    (define (%parse-until end-chars specials res port)
      (let ((char (read-char port)))
        (cond
          ((eq? char #\\)
           (let ((escaped (read-char port)))
             (%parse-until end-chars specials
                           (scone res escaped) port)))
          ((or (eof-object? char)
               (member char end-chars)) (append res '()))
          ((member char specials)
           (let ((special-block (switch-special char port)))
             (%parse-until end-chars specials
                           (scone res special-block) port)))
          (else
            (%parse-until end-chars specials
                          (scone res char) port)))))

    (define (%parse-paragraph res port)
      (let ((next (peek-char port)))
        (if (or (eof-object? next) (eq? #\newline next))
          (append res '())
          (let ((line (parse-line port)))
            (%parse-paragraph
              (append res (cons #\space line)) port)))))

    (define (%parse res special port)
      (let ((next (peek-char port)))
        (cond
          ((eof-object? next) (append res '()))

          ((or (eq? #\newline next) (eq? #\space next))
           (let ((_ (read-char port)))
             (%parse res special port)))

          ((member next special)
           (let ((special-line
                   (switch-special-line (read-char port) port)))
             (%parse (scone res special-line) special port)))

          (else
            (let ((paragraph (parse-paragraph port)))
              (%parse (scone res paragraph) special port))))))

    (define (switch-special type port)
      (let ((next (peek-char port)))
        (cond
          ((or (eq? type #\_) (eq? type #\*))
           (if (or (eq? next #\_) (eq? next #\*))
             (cons 'strong (parse-strong type port))
             (cons 'em (parse-line-until type port))))
          ((eq? type #\[) (cons 'a (parse-link port)))
          ((eq? type #\`) (cons 'code (parse-line-until #\` port)))
          (else (error (string-append "Not a special character: "
                                      (string type)))))))

    (define (switch-special-line type port)
      (cond
        ((eq? type #\!) (cons 'figure (parse-img port)))
        ((eq? type #\-) (begin (parse-line port) '(hr)))))

    (define (parse-img port)
      (read-char port)
      (let ((title (list->string (%parse-until '(#\]) '() '() port))))
        (read-char port)
        (let ((link (list->string (%parse-until '(#\)) '() '() port))))
          `((img (@ (src ,link) (title ,title)))))))

    (define (parse-link port)
      (let ((name (%parse-until '(#\]) '() '() port)))
        (read-char port)
        (let ((link (list->string (%parse-until '(#\)) '() '() port))))
          (cons `(@ (href ,link)) name))))

    (define (parse-strong end port)
      (read-char port)
      (let ((text (%parse-until (list end) '() '() port)))
        (read-char port)
        text))

    (define (parse-line port)
      (%parse-until '(#\newline) special-inner '() port))

    (define (parse-line-until end port)
      (%parse-until (list #\newline end)
                    special-inner '() port))

    (define (parse-paragraph port) (%parse-paragraph '(p) port))
    (define (markdown->sxml port) (%parse '() special-line port))

    (define special-line '(#\! #\- ))
    (define special-inner '(#\* #\_ #\[ #\`))))
