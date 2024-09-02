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


;; Model

(define _e_model
  (_enum 
   '(MODEL_UNKNOWN MODEL_14M MODEL_17M MODEL_22M MODEL_33M MODEL_60M MODEL_70M
     MODEL_80M MODEL_109M MODEL_137M MODEL_160M MODEL_220M MODEL_250M MODEL_270M
     MODEL_335M MODEL_410M MODEL_450M MODEL_770M MODEL_780M MODEL_0_5B MODEL_1B
     MODEL_1_3B MODEL_1_4B MODEL_2B MODEL_2_8B MODEL_3B MODEL_4B MODEL_6B MODEL_6_9B
     MODEL_7B MODEL_8B MODEL_9B MODEL_11B MODEL_12B MODEL_13B MODEL_14B MODEL_15B
     MODEL_16B MODEL_20B MODEL_30B MODEL_34B MODEL_35B MODEL_40B MODEL_65B MODEL_70B
     MODEL_236B MODEL_314B MODEL_SMALL MODEL_MEDIUM MODEL_LARGE MODEL_XL MODEL_A2_7B
     MODEL_8x7B MODEL_8x22B MODEL_16x12B MODEL_10B_128x3_66B MODEL_57B_A14B MODEL_27B)))





#;(define-cstruct _llama_model
    ([type _e_model] ;;  type  = MODEL_UNKNOWN;
     [arch _llm_arch] ;; llm_arch    arch  = LLM_ARCH_UNKNOWN;
     [ftype _llama_ftype] ;; llama_ftype ftype = LLAMA_FTYPE_ALL_F32;
     [name _string] ;; std::string name = "n/a";
     [hparams _llama_hparams] ;; llama_hparams hparams = {};
     [vocab _llama_vocab] ;; llama_vocab   vocab;
     [ggml_tensor _ggml_tensor_ptr] ;; struct ggml_tensor * tok_embd;
     [type_embd _ggml_tensor_ptr] ;; struct ggml_tensor * type_embd;
     [pos_embd _ggml_tensor_ptr] ;; struct ggml_tensor * pos_embd;
     [tok_norm _ggml_tensor_ptr] ;; struct ggml_tensor * tok_norm;
     [tok_norm_b _ggml_tensor_ptr] ;; struct ggml_tensor * tok_norm_b;
     [output_norm _ggml_tensor_ptr] ;; struct ggml_tensor * output_norm;
     [output_norm_b _ggml_tensor_ptr] ;; struct ggml_tensor * output_norm_b;
     [output _ggml_tensor_ptr] ;; struct ggml_tensor * output;
     [output_b _ggml_tensor_ptr] ;; struct ggml_tensor * output_b;
     [output_norm_enc _ggml_tensor_ptr] ;; struct ggml_tensor * output_norm_enc;
     [layers _]
    std::vector<llama_layer> layers;

    llama_split_mode split_mode;
    int main_gpu;
    int n_gpu_layers;

    std::vector<std::string> rpc_servers;

    // gguf metadata
    std::unordered_map<std::string, std::string> gguf_kv;

    // layer -> buffer type mapping
    struct layer_buft {
        layer_buft() : buft_matrix(nullptr), buft(nullptr) {}
        layer_buft(ggml_backend_buffer_type_t matrix) : buft_matrix(matrix), buft(matrix) {}
        layer_buft(ggml_backend_buffer_type_t matrix, ggml_backend_buffer_type_t other) : buft_matrix(matrix), buft(other) {}

        ggml_backend_buffer_type_t buft_matrix; // matrices only - used by split buffers and backends that support only matrix multiplication
        ggml_backend_buffer_type_t buft;        // everything else
    };

    layer_buft buft_input;
    layer_buft buft_output;
    std::vector<layer_buft> buft_layer;

    // contexts where the model tensors metadata is stored
    std::vector<struct ggml_context *> ctxs;

    // the model memory buffers for the tensor data
    std::vector<ggml_backend_buffer_t> bufs;

    // model memory mapped files
    llama_mmaps mappings;

    // objects representing data potentially being locked in memory
    llama_mlocks mlock_bufs;
    llama_mlocks mlock_mmaps;

    // for quantize-stats only
    std::vector<std::pair<std::string, struct ggml_tensor *>> tensors_by_name;

    int64_t t_load_us = 0;
    int64_t t_start_us = 0;

    // keep track of loaded lora adapters
    std::set<struct llama_lora_adapter *> lora_adapters;

    ~llama_model() {
        for (struct ggml_context * ctx : ctxs) {
            ggml_free(ctx);
        }
        for (ggml_backend_buffer_t buf : bufs) {
;#ifdef GGML_USE_CUDA
            if (ggml_backend_buffer_get_type(buf) == ggml_backend_cpu_buffer_type()) {
                ggml_backend_cuda_unregister_host_buffer(ggml_backend_buffer_get_base(buf));
            }
;#endif
            ggml_backend_buffer_free(buf);
        }
        while (!lora_adapters.empty()) {
            llama_lora_adapter_free(*lora_adapters.begin());
        }
}))




;(define _llama_model_ptr (_cpointer _llama_model))





;; Params constructor-desctructor
(define-llama model-params-init
  (_fun -> _llama_model_params_ptr)
  #:c-id model_params_init)

(define-llama model-params-free
  (_fun _llama_model_params_ptr -> _void)
  #:c-id model_params_free)


;; Model constructor-desctructor
#;(define-llama llama-model-from-file
  (_fun _string _llama_model_params_ptr -> _llama_model_ptr)
  #:c-id llama_model_from_file)

#;(define-llama llama-free-model
    (_fun _llama_model_params_ptr -> _void)
    #:c-id llama_free_model)

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



;; Initialize
(define params (model-params-init))
(define model (model-init-from-file "./t5-v1_1-xxl-encoder-Q5_K_M.gguf" params))

;; Display
(llama-model-params-displayln params)
(model-print-ptr model)


;; Deallocate
(model-free model)
(model-params-free params)


