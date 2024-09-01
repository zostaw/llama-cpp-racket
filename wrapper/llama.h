// wrapper part (added from external script)
struct llama_model_params * model_params_init();
void model_params_free(struct llama_model_params * params);
void * model_init_from_file(const char * file_path, struct llama_model_params params);
void model_free(struct llama_model ** model);