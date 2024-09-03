#lang racket
(require ffi/unsafe
         ffi/unsafe/define)

(define-ffi-definer define-llama
  (ffi-lib
   (string-append
    (path->string (current-directory)) "wrapper/build/src/libllama.dylib")))


(define _llama_split_mode
  (_enum '(LLAMA_SPLIT_MODE_NONE = 0
           LLAMA_SPLIT_MODE_LAYER = 1
           LLAMA_SPLIT_MODE_ROW = 2)
         _uint32  ; Assuming it's an unsigned 32-bit integer
         #:unknown (lambda (x)
                     (cond [(eq? x 'LLAMA_SPLIT_MODE_NONE)  0]
                           [(eq? x 'LLAMA_SPLIT_MODE_LAYER) 1]
                           [(eq? x 'LLAMA_SPLIT_MODE_ROW)   2]
                           [else (error 'llama_split_mode "unknown enum value")]))))

(define-cstruct _llama_model_params
  ([n_gpu_layers                _int32]
   [split_mode                  _llama_split_mode]
   [main_gpu                    _int32]
   [tensor_split                _pointer]
   [rpc_servers                 _pointer]
   [progress_callback           _pointer]
   [progress_callback_user_data _pointer]
   [kv_overrides                _pointer]
   [vocab_only                  _bool]
   [use_mmap                    _bool]
   [use_mlock                   _bool]
   [check_tensors               _bool]))

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

(define _llama_model_params_ptr (_cpointer _llama_model_params))



;; Params constructor-desctructor
(define-llama model-params-init
  (_fun -> _llama_model_params_ptr)
  #:c-id model_params_init)

(define-llama model-params-free
  (_fun _llama_model_params_ptr -> _void)
  #:c-id model_params_free)



;; Model constructor-desctructor
(define _model_ptr
  (_cpointer _void))

(define-llama model-init-from-file
  (_fun _string _llama_model_params_ptr -> _model_ptr)
  #:c-id model_init_from_file)

(define-llama model-free
    (_fun _model_ptr -> _void)
    #:c-id model_free)

(define-llama model-print-ptr
  (_fun _model_ptr -> _void)
  #:c-id model_print_ptr_addr)



;; ctx constructor-desctructor
(define _ctx_ptr
  (_cpointer _void))

(define-llama context-init-from-model
  (_fun _model_ptr _llama_model_params_ptr -> _ctx_ptr)
  #:c-id context_init_from_model)

(define-llama context-free
    (_fun _ctx_ptr -> _void)
    #:c-id context_free)

(define-llama context-print-ptr
  (_fun _ctx_ptr -> _void)
  #:c-id context_print_ptr_addr)


;; Run


(define-llama run
  (_fun _ctx_ptr _string -> _bool)
  #:c-id run)

;; Initialize
(define params (model-params-init))
(define model (model-init-from-file "./t5-v1_1-xxl-encoder-Q5_K_M.gguf" params))
(define ctx (context-init-from-model model params))

;; Display
(llama-model-params-displayln params)
(model-print-ptr model)
(context-print-ptr ctx)
(run ctx "Some prompt...")

;; Deallocate
(context-free ctx)
(model-free model)
(model-params-free params)


