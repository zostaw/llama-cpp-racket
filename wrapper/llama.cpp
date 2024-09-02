// wrapper part (added from external script)
struct llama_model_params * model_params_init()
{
    struct llama_model_params * params = (struct llama_model_params *) malloc(sizeof(struct llama_model_params));
    *params = llama_model_default_params();
    return params;
}

void model_params_free(struct llama_model_params * params)
{
    free(params);
}

void * model_init_from_file(const char * file_path, struct llama_model_params params)
{
    //struct llama_model * model = (struct llama_model *) malloc(sizeof(struct llama_model));
    struct llama_model * model = llama_load_model_from_file(file_path, params);
    void* model_v_ptr = model;
    printf("[llama.cpp] - model_init_from_file - struct addr: %p\n", model);
    printf("[llama.cpp - model_init_from_file - void addr: %p\n", model_v_ptr);
    return model_v_ptr;
}

void model_print_ptr_addr(void * model_v_ptr) {
    struct llama_model * model = static_cast<struct llama_model *>(model_v_ptr);
    printf("[llama.cpp] - model_print_ptr_addr - void addr: %p\n", model_v_ptr);
    printf("[llama.cpp - model_print_ptr_addr - struct addr: %p\n", model);
    printf("[llama.cpp] - model_print_ptr_addr - model name: '%s'\n", model->name.c_str());
}

void model_free(void * model_v_ptr) {
    struct llama_model * model = static_cast<struct llama_model *>(model_v_ptr);
    free(model);
}