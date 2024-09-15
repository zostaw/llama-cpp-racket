#lang racket

(require "llama.rkt")
(require ffi/unsafe
         ffi/unsafe/define)


#| INITIALIZE |#
; complete path, because raw string doesn't work with llama-load-model-from-file if called from DrRacket
(define model-path
  (path->complete-path "model.gguf"))
#;(define model-path (path->complete-path "t5-v1_1-xxl-encoder-Q5_K_M.gguf"))
#;(define model-path (path->complete-path "gpt2.Q4_K_M.gguf"))
#;(define model-path (path->complete-path
                    "/Users/zostaw/projects/ai/models/Meta-Llama-3-8B-Instruct.Q5_K_M.gguf"))

(define model-params
  (llama-model-default-params))
(define model
  (llama-load-model-from-file model-path model-params))

(define ctx-params
  (llama-context-default-params))
(define ctx
  (llama-new-context-with-model model ctx-params))

(define add-special
  (llama-add-bos-token model))
(define pooling-type
  (llama-pooling-type ctx))
(define max-tokens 100)
(define n-seq-max
  (llama-n-seq-max ctx))




#| TOKENIZE |#
(define tokenize
  (tokenizer model
             max-tokens
             add-special
             #f))

(define token-to-piece
  (token-to-piecer model
                   1
                   #t))

; Tokenize from input text
(define text "This is some random text to tokenize")
(define-values (tokens tokens-len) (tokenize text))

; Display
(define (print-tokens tokens tokens-len)
  (displayln "\nTokens:")
  (for/list ([i (range tokens-len)])
    (define token (ptr-ref tokens _llama_token i))
    (define piece (token-to-piece token))
    (displayln
     (format "  token ~a: ~a, piece: \"~a\""
             i
             token
             piece)))
  (newline))

(print-tokens tokens tokens-len)
 


#| DEALLOCATE |#
(llama-free-context ctx)
(llama-free-model model)

