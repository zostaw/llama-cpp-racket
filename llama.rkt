#lang racket
(require ffi/unsafe
         ffi/unsafe/define)


(define-ffi-definer define-llama
  (ffi-lib "./wrapper/build/src/libllama.dylib"))


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

;; Define the functions
(define-llama model-params-init
  (_fun -> _llama_model_params_ptr)
  #:c-id model_params_init)

(define-llama model-params-free
  (_fun _llama_model_params_ptr -> _void)
  #:c-id model_params_free)

(define params (model-params-init))



(llama-model-params-displayln params)
(model-params-free params)


