#lang racket
(require ffi/unsafe
         ffi/unsafe/define)

(provide (all-defined-out))



(define-ffi-definer define-llama
  (ffi-lib "libllama"))



;; Types definitions (they're mostly used for params structs declarations).
;; It's gonna be long,
;; but the interesting part begins where parameters are defined and struct declarations start.

(define _llama_pos _int32)
(define _llama_token _int32)
(define _llama_seq_id _int32)

(define _llama_split_mode
  (_enum '(LLAMA_SPLIT_MODE_NONE = 0
           LLAMA_SPLIT_MODE_LAYER = 1
           LLAMA_SPLIT_MODE_ROW = 2)
         _uint32
         #:unknown (lambda (x)
                     (cond [(eq? x 'LLAMA_SPLIT_MODE_NONE)  0]
                           [(eq? x 'LLAMA_SPLIT_MODE_LAYER) 1]
                           [(eq? x 'LLAMA_SPLIT_MODE_ROW)   2]
                           [else (error 'llama_split_mode "unknown enum value")]))))

(define _ggml_type
  (_enum '(GGML_TYPE_F32 = 0
           GGML_TYPE_F16 = 1
           GGML_TYPE_Q4_0 = 2
           GGML_TYPE_Q4_1 = 3
           GGML_TYPE_Q5_0 = 6
           GGML_TYPE_Q5_1 = 7
           GGML_TYPE_Q8_0 = 8
           GGML_TYPE_Q8_1 = 9
           GGML_TYPE_Q2_K = 10
           GGML_TYPE_Q3_K = 11
           GGML_TYPE_Q4_K = 12
           GGML_TYPE_Q5_K = 13
           GGML_TYPE_Q6_K = 14
           GGML_TYPE_Q8_K = 15
           GGML_TYPE_IQ2_XXS = 16
           GGML_TYPE_IQ2_XS = 17
           GGML_TYPE_IQ3_XXS = 18
           GGML_TYPE_IQ1_S = 19
           GGML_TYPE_IQ4_NL = 20
           GGML_TYPE_IQ3_S = 21
           GGML_TYPE_IQ2_S = 22
           GGML_TYPE_IQ4_XS = 23
           GGML_TYPE_I8 = 24
           GGML_TYPE_I16 = 25
           GGML_TYPE_I32 = 26
           GGML_TYPE_I64 = 27
           GGML_TYPE_F64 = 28
           GGML_TYPE_IQ1_M = 29
           GGML_TYPE_BF16 = 30
           GGML_TYPE_Q4_0_4_4 = 31
           GGML_TYPE_Q4_0_4_8 = 32
           GGML_TYPE_Q4_0_8_8 = 33
           GGML_TYPE_TQ1_0 = 34
           GGML_TYPE_TQ2_0 = 35
           GGML_TYPE_COUNT
          )
          _uint32
          #:unknown (lambda (x)
                     (cond ((eq? x 'GGML_TYPE_F32) 0)
                           ((eq? x 'GGML_TYPE_F16) 1)
                           ((eq? x 'GGML_TYPE_Q4_0) 2)
                           ((eq? x 'GGML_TYPE_Q4_1) 3)
                           ((eq? x 'GGML_TYPE_Q5_0) 6)
                           ((eq? x 'GGML_TYPE_Q5_1) 7)
                           ((eq? x 'GGML_TYPE_Q8_0) 8)
                           ((eq? x 'GGML_TYPE_Q8_1) 9)
                           ((eq? x 'GGML_TYPE_Q2_K) 10)
                           ((eq? x 'GGML_TYPE_Q3_K) 11)
                           ((eq? x 'GGML_TYPE_Q4_K) 12)
                           ((eq? x 'GGML_TYPE_Q5_K) 13)
                           ((eq? x 'GGML_TYPE_Q6_K) 14)
                           ((eq? x 'GGML_TYPE_Q8_K) 15)
                           ((eq? x 'GGML_TYPE_IQ2_XXS) 16)
                           ((eq? x 'GGML_TYPE_IQ2_XS) 17)
                           ((eq? x 'GGML_TYPE_IQ3_XXS) 18)
                           ((eq? x 'GGML_TYPE_IQ1_S) 19)
                           ((eq? x 'GGML_TYPE_IQ4_NL) 20)
                           ((eq? x 'GGML_TYPE_IQ3_S) 21)
                           ((eq? x 'GGML_TYPE_IQ2_S) 22)
                           ((eq? x 'GGML_TYPE_IQ4_XS) 23)
                           ((eq? x 'GGML_TYPE_I8) 24)
                           ((eq? x 'GGML_TYPE_I16) 25)
                           ((eq? x 'GGML_TYPE_I32) 26)
                           ((eq? x 'GGML_TYPE_I64) 27)
                           ((eq? x 'GGML_TYPE_F64) 28)
                           ((eq? x 'GGML_TYPE_IQ1_M) 29)
                           ((eq? x 'GGML_TYPE_BF16) 30)
                           ((eq? x 'GGML_TYPE_Q4_0_4_4) 31)
                           ((eq? x 'GGML_TYPE_Q4_0_4_8) 32)
                           ((eq? x 'GGML_TYPE_Q4_0_8_8) 33)
                           ((eq? x 'GGML_TYPE_TQ1_0) 34)
                           ((eq? x 'GGML_TYPE_TQ2_0) 35)
                           ((eq? x 'GGML_TYPE_COUNT) (error 'ggml_type "unknown enum value"))
                           (else (error 'ggml_type "unknown enum value"))))))

(define _llama_rope_scaling_type
  (_enum '(LLAMA_ROPE_SCALING_TYPE_UNSPECIFIED = -1
           LLAMA_ROPE_SCALING_TYPE_NONE = 0
           LLAMA_ROPE_SCALING_TYPE_LINEAR = 1
           LLAMA_ROPE_SCALING_TYPE_YARN = 2
           LLAMA_ROPE_SCALING_TYPE_MAX_VALUE = 2
          )
          _int32
          #:unknown (lambda (x)
                     (cond ((eq? x 'LLAMA_ROPE_SCALING_TYPE_UNSPECIFIED) -1)
                           ((eq? x 'LLAMA_ROPE_SCALING_TYPE_NONE) 0)
                           ((eq? x 'LLAMA_ROPE_SCALING_TYPE_LINEAR) 1)
                           ((eq? x 'LLAMA_ROPE_SCALING_TYPE_YARN) 2)
                           ;; Originally the MAX_VALUE is pointing to YARN,
                           ;; in general I guess it should be whatever is biggest
                           ((eq? x 'LLAMA_ROPE_SCALING_TYPE_MAX_VALUE) 2)
                           (else (error 'llama_rope_scaling_type "unknown enum value"))))))

(define _llama_pooling_type
  (_enum '(LLAMA_POOLING_TYPE_UNSPECIFIED = -1
           LLAMA_POOLING_TYPE_NONE = 0
           LLAMA_POOLING_TYPE_MEAN = 1
           LLAMA_POOLING_TYPE_CLS = 2
           LLAMA_POOLING_TYPE_LAST = 3
          )
          _int32
          #:unknown (lambda (x)
                     (cond ((eq? x 'LLAMA_POOLING_TYPE_UNSPECIFIED) -1)
                           ((eq? x 'LLAMA_POOLING_TYPE_NONE) 0)
                           ((eq? x 'LLAMA_POOLING_TYPE_MEAN) 1)
                           ((eq? x 'LLAMA_POOLING_TYPE_CLS) 2)
                           ((eq? x 'LLAMA_POOLING_TYPE_LAST) 3)
                           (else (error 'llama_pooling_type "unknown enum value"))))))

(define _llama_attention_type
  (_enum '(LLAMA_ATTENTION_TYPE_UNSPECIFIED = -1
           LLAMA_ATTENTION_TYPE_CAUSAL = 0
           LLAMA_ATTENTION_TYPE_NON_CAUSAL = 1
          )
          _int32
          #:unknown (lambda (x)
                     (cond ((eq? x 'LLAMA_ATTENTION_TYPE_UNSPECIFIED) -1)
                           ((eq? x 'LLAMA_ATTENTION_TYPE_CAUSAL) 0)
                           ((eq? x 'LLAMA_ATTENTION_TYPE_NON_CAUSAL) 1)
                           (else (error 'llama_attention_type "unknown enum value"))))))


(define _ggml_backend_sched_eval_callback (_fun _pointer _bool _pointer -> _bool))
(define _ggml_abort_callback (_fun _pointer -> _bool))

(define _llama_vocab_type
  (_enum '(LLAMA_VOCAB_TYPE_NONE = 0 ; For models without vocab
           LLAMA_VOCAB_TYPE_SPM  = 1 ; LLaMA tokenizer based on byte-level BPE with byte fallback
           LLAMA_VOCAB_TYPE_BPE  = 2 ; GPT-2 tokenizer based on byte-level BPE
           LLAMA_VOCAB_TYPE_WPM  = 3 ; BERT tokenizer based on WordPiece
           LLAMA_VOCAB_TYPE_UGM  = 4 ; T5 tokenizer based on Unigram
           LLAMA_VOCAB_TYPE_RWKV = 5 ; RWKV tokenizer based on greedy tokenization
         )
         _uint32
         #:unknown (lambda (x)
                     (cond
                       ((eq? x 'LLAMA_VOCAB_TYPE_NONE) 0)
                       ((eq? x 'LLAMA_VOCAB_TYPE_SPM) 1)
                       ((eq? x 'LLAMA_VOCAB_TYPE_BPE) 2)
                       ((eq? x 'LLAMA_VOCAB_TYPE_WPM) 3)
                       ((eq? x 'LLAMA_VOCAB_TYPE_UGM) 4)
                       ((eq? x 'LLAMA_VOCAB_TYPE_RWKV) 5)
                       (else (error 'llama_vocab_type "unknown enum value"))))))



;; Params and context params
; Structs
(define-cstruct _llama_model_params
  ([n_gpu_layers                         _int32]
   [split_mode                _llama_split_mode]
   [main_gpu                             _int32]
   [tensor_split                       _pointer]
   [rpc_servers                        _pointer]
   [progress_callback                  _pointer]
   [progress_callback_user_data        _pointer]
   [kv_overrides                       _pointer]
   [vocab_only                            _bool]
   [use_mmap                              _bool]
   [use_mlock                             _bool]
   [check_tensors                         _bool]))

(define-cstruct _llama_context_params
  ([n_ctx                               _uint32]
   [n_batch                             _uint32]
   [n_ubatch                            _uint32]
   [n_seq_max                           _uint32]
   [n_threads                            _int32]
   [n_threads_batch                      _int32]

   [rope_scaling_type  _llama_rope_scaling_type]
   [pooling_type            _llama_pooling_type]
   [attention_type        _llama_attention_type]

   [rope_freq_base                       _float]
   [rope_freq_scale                      _float]
   [yarn_ext_factor                      _float]
   [yarn_attn_factor                     _float]
   [yarn_beta_fast                       _float]
   [yarn_beta_slow                       _float]
   [yarn_orig_ctx                       _uint32]
   [defrag_thold                         _float]

   [cb_eval   _ggml_backend_sched_eval_callback]
   [cb_eval_user_data                  _pointer]

   [type_k                           _ggml_type]
   [type_v                           _ggml_type]

   [logits_all                            _bool]
   [embeddings                            _bool]
   [offload_kqv                           _bool]
   [flash_attn                            _bool]

   [abort_callback         _ggml_abort_callback]
   [abort_callback_data                _pointer]))

;; Constructors
(define-llama llama-model-default-params
  (_fun -> _llama_model_params)
  #:c-id llama_model_default_params)

(define-llama llama-context-default-params
  (_fun -> _llama_context_params)
  #:c-id llama_context_default_params)




;; Model constructor-destructor
(define _llama_model
  (_cpointer _void))

(define-llama llama-load-model-from-file
  (_fun _string _llama_model_params -> _llama_model)
  #:c-id llama_load_model_from_file)

(define-llama llama-free-model
    (_fun _llama_model -> _void)
    #:c-id llama_free_model)

;; Model util functions
; Add bos - determines if bos tokens are used in the model
(define-llama llama-add-bos-token
  (_fun _llama_model -> _bool)
  #:c-id llama_add_bos_token)

(define-llama llama-model-size
  (_fun _llama_model -> _uint64)
  #:c-id llama_model_size)

(define-llama llama-model-n-params
  (_fun _llama_model -> _uint64)
  #:c-id llama_model_n_params)

(define-llama llama-model-has-encoder
  (_fun _llama_model -> _bool)
  #:c-id llama_model_has_encoder)

(define-llama llama-model-has-decoder
  (_fun _llama_model -> _bool)
  #:c-id llama_model_has_decoder)

(define-llama llama-model-decoder-start-token
  (_fun _llama_model -> _llama_token)
  #:c-id llama_model_decoder_start_token)

(define-llama llama-n-vocab
  (_fun _llama_model -> _int32)
  #:c-id llama_n_vocab)

(define-llama llama-n-ctx-train
  (_fun _llama_model -> _int32)
  #:c-id llama_n_ctx_train)

(define-llama llama-n-embd
  (_fun _llama_model -> _int32)
  #:c-id llama_n_embd)

(define-llama llama-n-layer
  (_fun _llama_model -> _int32)
  #:c-id llama_n_layer)




;; Context constructor-destructor
(define _llama_context
  (_cpointer _void))

(define-llama llama-new-context-with-model
  (_fun _llama_model _llama_context_params -> _llama_context)
  #:c-id llama_new_context_with_model)

(define-llama llama-free-context
    (_fun _llama_context -> _void)
    #:c-id llama_free)

;; Context util functions
(define-llama llama-kv-cache-clear
  (_fun _llama_context -> _void)
  #:c-id llama_kv_cache_clear)

(define-llama llama-get-model
  (_fun _llama_context -> _llama_model)
  #:c-id llama_get_model)

; TODO: check if that function is correct - it returns float pointer, but in original description it appears to be matrix, so it might require some special way of handling.
(define-llama llama-get-logits
  (_fun _llama_context -> _pointer)
  #:c-id llama_get_logits)

(define-llama llama-get-logits-ith
  (_fun _llama_context _int32 -> _pointer)
  #:c-id llama_get_logits_ith)

(define-llama llama-pooling-type
  (_fun _llama_context -> _llama_pooling_type)
  #:c-id llama_pooling_type)

(define-llama llama-n-ctx
  (_fun _llama_context -> _uint32)
  #:c-id llama_n_ctx)

(define-llama llama-n-batch
  (_fun _llama_context -> _uint32)
  #:c-id llama_n_batch)

(define-llama llama-n-ubatch
  (_fun _llama_context -> _uint32)
  #:c-id llama_n_ubatch)

(define-llama llama-n-seq-max
  (_fun _llama_context -> _int32)
  #:c-id llama_n_seq_max)




;; Tokenizer
(define-llama llama-tokenize
  (_fun _llama_model
        _string
        _int32
        [vec : (_vector i _llama_token)]
        _int32
        _bool
        _bool
        -> [res : _int32]
        -> (values vec res))
  #:c-id llama_tokenize)

; This function produces closure that takes only text string as argument.
(define (tokenizer model
                   max-tokens
                   add-special
                   parse-special)
  (define tokens-vector (make-vector max-tokens 0))
  ; The lambda function takes String and returns: num-tokens (Integer), tokens (Vector<Integer>)
  (λ (text) (llama-tokenize model
                            text
                            (string-length text)
                            tokens-vector
                            max-tokens
                            add-special
                            parse-special)))




;; Token -> Piece
(define-llama llama-token-to-piece
  (_fun _llama_model
        _llama_token
        [piece : (_bytes o len)] ; this arg is implicit -  should be skipped in function call
        [len : _int32] ; but don't skip this one
        _int32
        _bool
        -> [res : _int32]
        -> (values piece res))
  #:c-id llama_token_to_piece)

(define (token-to-piecer model lstrip special)
  #|
  Closure that once defined can be called with token as argument.
  For example, you first initiate token-to-piecer (assuming you already have _llama_model object initialized):
  (define token-to-piece
     (token-to-piecer model ; model - type: _llama_model
                      1     ; lstrip - type int
                      #t    ; special - type: bool
  ))
  Then you can use the closure on given token, ie.:
  (token-to-piece 69)

  
  A more complete example would be this one, using tokenize function first:
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
      (displayln (format "token: ~a, piece: \"~a\"" token (token-to-piece token) ))))
|#
  (define (generate-token token [llama-token-max-len 1])
    (define-values (piece res)
      (llama-token-to-piece model
                            token
                            ;piece char*
                            llama-token-max-len ; len of piece
                            lstrip
                            special))
    (cond
      [(not (exact-integer? res))
       (error "token_to_piecer was supposed to return exact-integer res, but received: " res)]
      [(positive? res) piece]
      [(negative? res) (generate-token token
                                       (+ llama-token-max-len
                                          (abs res)))]))
  ; Return closure
  (λ (token) (generate-token token)))




;; Embeddings
(define _float_ptr
  (_cpointer _float))

(define-llama llama-get-embeddings-ith
  (_fun _llama_context _int32 -> _float_ptr)
  #:c-id llama_get_embeddings_ith)

(define-llama llama-get-embeddings-seq
  (_fun _llama_context _llama_seq_id -> _float_ptr)
  #:c-id llama_get_embeddings_seq)




;; Batch struct
(define-cstruct _llama_batch
  ([n_tokens                            _int32]
   [token                             _pointer]
   [embd                              _pointer] 
   [pos                               _pointer]
   [n_seq_id                          _pointer]
   [seq_id                            _pointer]
   [logits                            _pointer]
   [all_pos_0                       _llama_pos]
   [all_pos_1                       _llama_pos]
   [all_seq_id                   _llama_seq_id]))

;; This function will become obsolete later according to llama.cpp comments.
;; I mapped it because I couldn't make llama-batch-init work for a long time...
(define-llama llama-batch-get-one
  (_fun _pointer
        _int32 ; n_tokens
        _llama_pos ; pos_0
        _llama_seq_id ; seq_id
        -> _llama_batch)
  #:c-id llama_batch_get_one)

#|
   This is *proper* way of allocating space for batch struct, but it's a bit complicated.
   Upon initializing it's useless, you need to manually handle adding tokens into it.
   In original code, they have a *common.cpp* helper functions that do that,
   but it's CPP code, so doesn't come with libllama.
   I reproduced the same function below *llama-batch-add* - it's basically the same.
|#
(define-llama llama-batch-init
  (_fun _int32 ; n_tokens
        _int32 ; embd
        _int32 ; n_seq_max
        -> _llama_batch)
  #:c-id llama_batch_init)

(define-llama llama-batch-free
  (_fun _llama_batch -> _void)
  #:c-id llama_batch_free)

;; This function comes from common.cpp, it's necessary when calling llama-batch-init'ed batch, otherwise the batch structure unusable. Alternative is to use llama-batch-get-one.
; _llama_batch _llama_token _llama_pos vector?<llama_seq_id> _bool -> _void
(define (llama-batch-add batch id pos seq-ids logits)
  (define n-tokens (llama_batch-n_tokens batch))
  
  (ptr-set! (llama_batch-token batch)     _llama_token    n-tokens   id)
  (ptr-set! (llama_batch-pos batch)       _llama_pos      n-tokens   pos)
  (ptr-set! (llama_batch-n_seq_id batch)  _llama_seq_id   n-tokens   (vector-length seq-ids))

  (for/list ([id (range (vector-length seq-ids))])
    (ptr-set!
     (ptr-ref (llama_batch-seq_id batch) _pointer n-tokens)
     _llama_seq_id id (vector-ref seq-ids id)))
  
  (ptr-set! (llama_batch-logits batch) _bool n-tokens logits)
  (ptr-set! batch _int32 (add1 n-tokens)))

;; This is also from common.cpp
(define (llama-batch-clear batch)
  (ptr-set! batch _int32 0))

;; Encode-decode (also see *llama-model-has-encoder* and *llama-model-has-decoder* functions in *model* section).
(define-llama llama-encode
  (_fun _llama_context _llama_batch -> _int32)
  #:c-id llama_encode)

(define-llama llama-decode
  (_fun _llama_context _llama_batch -> _int32)
  #:c-id llama_decode)


