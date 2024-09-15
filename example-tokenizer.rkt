#lang racket

(require "llama.rkt")
(require ffi/unsafe
         ffi/unsafe/define)



(define (print-llama-batch batch)
  (define n-tokens (llama_batch-n_tokens batch))
  (displayln (format "batch: ~a"
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




#| INITIALIZE |#
; complete path, because raw string doesn't work with llama-load-model-from-file if called from DrRacket
(define model-path (path->complete-path "t5-v1_1-xxl-encoder-Q5_K_M.gguf"))
;(define model-path (path->complete-path "gpt2.Q4_K_M.gguf"))
#;(define model-path (path->complete-path
                    "/Users/zostaw/projects/ai/models/Meta-Llama-3-8B-Instruct.Q5_K_M.gguf"))

(define model-params (llama-model-default-params))
(define model (llama-load-model-from-file model-path model-params))

(define ctx-params (llama-context-default-params))
(define ctx (llama-new-context-with-model model ctx-params))

(define add-special (llama-add-bos-token model))
(define pooling-type (llama-pooling-type ctx))
(define max-tokens 100)
(define n-seq-max (llama-n-seq-max ctx))




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
(for/list ([i (range tokens-len)])
  (let ([token (ptr-ref tokens _llama_token i)])
    (define piece (token-to-piece token))
    (displayln (format "token: ~a, piece: \"~a\""
                       token
                       piece))))
(displayln "\n____________________________________________________________________________________\n")
  



#| BATCH |#
(llama-kv-cache-clear ctx)

; Initialize
(define batch
  (llama-batch-init max-tokens 0 n-seq-max))

; Build from tokens
(let ([seq-ids (make-vector 512 0)])
  (for/list ([i (range tokens-len)])
    (let ([token (ptr-ref tokens _llama_token i)])
      (llama-batch-add batch token 0 seq-ids #f)
      (print-llama-batch batch)))
      (displayln "____________________________________________________________________________________\n"))

; Encode-decode
(when (llama-model-has-encoder model)
  (displayln (format "Encode ret: ~a\n"
                     (llama-encode ctx batch))))
(when (llama-model-has-decoder model)
  (displayln (format "Decode ret: ~a\n"(llama-decode ctx batch))))

(displayln
 (format "Logits: ~a" (map (λ (i) (ptr-ref (llama-get-logits ctx) _int8 i))
                           (range 50))))

; Clean batch (after that we could reuse it for another batch)
(llama-batch-clear batch)
; and deallocate
(llama-batch-free batch)




;; Deallocate
(llama-free-context ctx)
(llama-free-model model)

