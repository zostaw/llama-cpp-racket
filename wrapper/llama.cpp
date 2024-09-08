// wrapper part (added from external script)

/*  Model */

void model_print_ptr_addr(void * model_v_ptr) {
    struct llama_model * model = static_cast<struct llama_model *>(model_v_ptr);
    printf("[llama.cpp] - model_print_ptr_addr - void addr: %p\n", model_v_ptr);
    printf("[llama.cpp - model_print_ptr_addr - struct addr: %p\n", model);
    printf("[llama.cpp] - model_print_ptr_addr - model name: '%s'\n", model->name.c_str());
}

/* Context */

void context_print_ptr_addr(void * ctx_v_ptr) {
    struct llama_context * ctx = static_cast<struct llama_context *>(ctx_v_ptr);
    printf("[llama.cpp] - context_print_ptr_addr - void addr: %p\n", ctx_v_ptr);
    printf("[llama.cpp - context_print_ptr_addr - struct addr: %p\n", ctx);
    printf("[llama.cpp] - context_print_ptr_addr - context -> model -> name: '%s'\n", ctx->model.name.c_str());
}

