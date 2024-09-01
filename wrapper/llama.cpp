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
    void* model_ptr = &model;
    printf("CPP side struct: %p\n", model);
    printf("CPP side void: %p\n", model_ptr);
    return model_ptr;
}

void model_free(struct llama_model ** model) {
    free(*model);
}