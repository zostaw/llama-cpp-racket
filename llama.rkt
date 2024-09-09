#lang racket
(require ffi/unsafe
         ffi/unsafe/define)




(define-ffi-definer define-llama
  (ffi-lib
   (string-append
    (path->string (current-directory)) "wrapper/build/src/libllama.dylib")))




;; Types definitions (they're mostly used for params structs declarations)
;; It's gonna be long, the interesting part begins where types definitions end and struct declarations begin

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

(define _llama_token _int32)

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

;; Printer function/s
(define (llama-model-params-displayln params)
  (displayln
   (format "n_gpu_layers: ~a \nsplit_mode: ~a \nmain_gpu: ~a \ntensor_split: ~a \nrpc_servers: ~a \nprogress_callback: ~a \nprogress_callback_user_data: ~a \nkv_overrides: ~a \nvocab_only: ~a \nuse_mmap: ~a \nuse_mlock: ~a \ncheck_tensors: ~a"
           (ptr-ref params _int32 0)
           (ptr-ref params _llama_split_mode 1)
           (ptr-ref params _int32 2)
           (ptr-ref params _pointer 3)
           (ptr-ref params _pointer 4)
           (ptr-ref params _pointer 5)
           (ptr-ref params _pointer 6)
           (ptr-ref params _pointer 7)
           (ptr-ref params _bool 8)
           (ptr-ref params _bool 9)
           (ptr-ref params _bool 10)
           (ptr-ref params _bool 11))))




;; Model constructor-destructor
(define _llama_model
  (_cpointer _void))

(define-llama llama-load-model-from-file
  (_fun _string _llama_model_params -> _llama_model)
  #:c-id llama_load_model_from_file)

(define-llama llama-free-model
    (_fun _llama_model -> _void)
    #:c-id llama_free_model)

(define-llama model-print-ptr
  (_fun _llama_model -> _void)
  #:c-id model_print_ptr_addr)




;; Context constructor-destructor
(define _llama_context
  (_cpointer _void))

(define-llama llama-new-context-with-model
  (_fun _llama_model _llama_context_params -> _llama_context)
  #:c-id llama_new_context_with_model)

(define-llama llama-free-context
    (_fun _llama_context -> _void)
    #:c-id llama_free)

(define-llama context-print-ptr
  (_fun _llama_context -> _void)
  #:c-id context_print_ptr_addr)




;; Tokenizer
;_llama_token
(define-llama llama-tokenize
  (_fun
   _llama_model
   _string
   _int32
   [vec : (_vector i _llama_token)]
   _int32
   _bool
   _bool
   -> [res : _int32]
   -> (values vec res))
  #:c-id llama_tokenize)

(define (tokenizer model max-tokens add-special parse-special)
  (define tokens-vector (make-vector max-tokens 0))
  (λ (text) (llama-tokenize model
                            text
                            (string-length text)
                            tokens-vector
                            max-tokens
                            add-special
                            parse-special)))




;; Initialize
(define model-params (llama-model-default-params))
(define model (llama-load-model-from-file "./t5-v1_1-xxl-encoder-Q5_K_M.gguf" model-params))
(define ctx-params (llama-context-default-params))
(define ctx (llama-new-context-with-model model ctx-params))
(define tokenize
   (tokenizer model 100 #t #t))

;; Display some params and other info...
(llama-model-params-displayln model-params)
(model-print-ptr model)
(context-print-ptr ctx)

;; Tokenize from input text
(define text (read-line))
(define-values (tokens tokens-len) (tokenize text))
(for ([i (in-range tokens-len)])
  (println (ptr-ref tokens _llama_token i)))

;; Deallocate
(llama-free-context ctx)
(llama-free-model model)
