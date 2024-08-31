#lang racket

(require racket/file)
(require racket/contract)

(define-values (backup-llama-h wrapper-llama-h target-llama-h)
   (vector->values
    (let ([args (current-command-line-arguments)])
      (cond 
        [(not (equal? 3 (vector-length args)))
         (error "Expected 3 args: <backup llama.h> <wrapper llama.h> <target llama.h>")]
        [(not (foldl (lambda (arg acc) 
                       (and acc (file-exists? arg))) 
                     #t 
                     (vector->list args)))
         (error "Expected 3 files, but at least some aren't.")])
      args)))



(define/contract (process-file backup-file wrapper-file target-file put-before-line-str)
  (-> file-exists? file-exists? file-exists? string? void?)

  
  (define wrapper-file-content
    (file->string wrapper-file))
  

  (define/contract (inject-lines inp acc-content wrapper-file-content put-before-line-str)
    (-> input-port? string? string? string? (or/c string? eof-object?))
    
    (define line (read-line inp 'any))
    
    (if (eof-object? line)
        acc-content
        (inject-lines inp
                      (string-append acc-content
                                     (if (equal? line put-before-line-str)
                                         (string-append wrapper-file-content "\n" line)
                                         line)
                                     "\n")
                      wrapper-file-content
                      put-before-line-str)))

  
  (define/contract (wrap-text original-file wrapper put-before-line-str)
    (-> file-exists? file-exists? string? string?)
      (define inp
        (open-input-file original-file))
      (define result
        (inject-lines inp "" wrapper-file-content put-before-line-str))
      (close-input-port inp)
      result)

  (define/contract (write-text text target)
    (-> string? file-exists? void?)
    (with-output-to-file target
      (λ () (fprintf (current-output-port) "~a" text))
      #:exists 'truncate))

  (write-text (wrap-text backup-file wrapper-file put-before-line-str)
              target-file))


(process-file backup-llama-h
              wrapper-llama-h
              target-llama-h
              "    struct llama_model_params {")
