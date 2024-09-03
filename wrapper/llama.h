// wrapper part (added from external script)
struct llama_model_params * model_params_init();
void model_params_free(struct llama_model_params * params);
void * model_init_from_file(const char * file_path, struct llama_model_params params);
void model_free(void * model_v_ptr);
void model_print_ptr_addr(void * model_v_ptr);
void * context_init_from_model(void * model_v_ptr);
void context_free(void * ctx_v_ptr);
void context_print_ptr_addr(void * ctx_v_ptr);
static bool run(void * ctx_v_ptr, const char * prompt);
