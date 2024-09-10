#lang racket

(require "llama.rkt")
(require ffi/unsafe
         ffi/unsafe/define)

;; Initialize
(define model-path (path->complete-path "t5-v1_1-xxl-encoder-Q5_K_M.gguf"))
(define model-params (llama-model-default-params))
(define model (llama-load-model-from-file model-path model-params))
(define ctx-params (llama-context-default-params))
(define ctx (llama-new-context-with-model model ctx-params))
(define add-special (llama-add-bos-token model))
(define tokenize
   (tokenizer model
              100
              add-special
              #f))
(define token-to-piece
  (token-to-piecer model
                   1
                   #t))


;; Tokenize from input text
(define text "This is some random text to tokenize")
(define-values (tokens tokens-len) (tokenize text))
(for ([i (in-range tokens-len)])
  (let ([token (ptr-ref tokens _llama_token i)])
    (define piece (token-to-piece token))
    (displayln (format "token: ~a, piece: \"~a\"" token piece ))))
  

;; Deallocate
(llama-free-context ctx)
(llama-free-model model)

