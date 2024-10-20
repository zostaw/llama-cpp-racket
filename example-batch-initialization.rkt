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
(define max-tokens 300)
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
(define text "Alpha beta gamma")
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




#| BATCH |#
; This call is optional, doesn't really do anything in this example, but might be worth to do in a iterative process.
(llama-kv-cache-clear ctx)

; Initialize
(define batch
  (llama-batch-init max-tokens 0 n-seq-max))



(define (print-llama-batch batch)
  (define n-tokens (llama_batch-n_tokens batch))
  (displayln
   (format "  batch: ~a"
           (add-between
            (list n-tokens
                  (for/fold ([acc '()]
                             #:result (reverse acc))
                            ([i (range n-tokens)])
                    (cons (ptr-ref (llama_batch-token batch)
                                   _llama_token i)
                          acc))
                  (llama_batch-embd batch)
                  (llama_batch-pos batch)
                  (llama_batch-n_seq_id batch)
                  (llama_batch-seq_id batch)
                  (llama_batch-logits batch)
                  (llama_batch-all_pos_0 batch)
                  (llama_batch-all_pos_1 batch)
                  (llama_batch-all_seq_id batch))
            "|"))))

; Build from tokens
(let ([seq-ids (build-vector 512 (lambda (x) x))])
  (displayln "Build up batch:")
  (for/list ([i (range tokens-len)])
    (let ([token (ptr-ref tokens _llama_token i)])
      (llama-batch-add batch token 0 seq-ids #t)
      (print-llama-batch batch)))
  (displayln "____________________________________________________________________________________\n"))


(define n-tokens (llama_batch-n_tokens batch))

(when (llama-model-has-encoder model)
  (displayln (format "Encode ret code: ~a\n"
                     (llama-encode ctx batch))))
(when (llama-model-has-decoder model)
  (displayln (format "Decode ret code: ~a\n"
                     (llama-decode ctx batch))))


(displayln
 (format "First ~a logits: ~a"
         n-tokens
         (map (λ (i)
                (ptr-ref (llama-get-logits ctx) _int8 i))
              (range n-tokens))
         ))

(displayln
 (format "First ~a logits: ~a"
         n-tokens
         (map (λ (i)
                (ptr-ref (ptr-ref batch _pointer 6) _int8 i))
              (range n-tokens))))

; Clean batch (we could reuse it for the next portion to process after that)
;(llama-batch-clear batch)




;; Deallocate
; Usually this would be cleaned at the end of scope for batch
;(llama-batch-free batch)
; These would be cleaned when switching ctx/model
;(llama-free-context ctx)
;(llama-free-model model)

