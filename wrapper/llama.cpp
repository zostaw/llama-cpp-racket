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

