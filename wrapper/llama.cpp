// wrapper part (added from external script)


/* Params */

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


/*  Model */

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


/* Context */


void * context_init_from_model(void * model_v_ptr) {
    struct llama_model * model = static_cast<struct llama_model *>(model_v_ptr);
    struct llama_context_params ctx_params = llama_context_default_params();
    struct llama_context * ctx = llama_new_context_with_model(model, ctx_params);
    void* ctx_v_ptr = ctx;
    printf("[llama.cpp] - context_init_from_file - struct addr: %p\n", ctx);
    printf("[llama.cpp - context_init_from_file - void addr: %p\n", ctx_v_ptr);
    return ctx_v_ptr;
}

void context_print_ptr_addr(void * ctx_v_ptr) {
    struct llama_context * ctx = static_cast<struct llama_context *>(ctx_v_ptr);
    printf("[llama.cpp] - context_print_ptr_addr - void addr: %p\n", ctx_v_ptr);
    printf("[llama.cpp - context_print_ptr_addr - struct addr: %p\n", ctx);
    printf("[llama.cpp] - context_print_ptr_addr - context -> model -> name: '%s'\n", ctx->model.name.c_str());
}

void context_free(void * ctx_v_ptr) {
    struct llama_context * ctx = static_cast<struct llama_context *>(ctx_v_ptr);
    free(ctx);
}


static bool run(void * ctx_v_ptr, const char * prompt) {
    struct llama_context * ctx = static_cast<struct llama_context *>(ctx_v_ptr);
    const bool add_bos = llama_add_bos_token(llama_get_model(ctx));

    std::vector<llama_token> tokens = ::llama_tokenize(ctx, prompt, add_bos);

    if (llama_decode(ctx, llama_batch_get_one(tokens.data(), tokens.size(), 0, 0))) {
        fprintf(stderr, "%s : failed to eval\n", __func__);
        return false;
    }

    return true;
}