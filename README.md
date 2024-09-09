# llama.cpp over FFI into Racket

This repository servers purely practical purpose for my project.  
It adds few wrapper functions to original repo and builds *dylib*.  
Right now, it only has a wrapper for llama_params, I plan to add loading model and reading embedding results + outputs.  
I do not plan to add any other functions, in the near future.  
But please feel free to use/change it.  

It was last tested with llama.cpp commit *a47667cff41f5a198eb791974e0afcc1cddd3229*,  
but I suspect it will work with any version, I only added few wrapper functions inside llama.cpp and llama.h.  

# Usage

1. Clone the repo and initialize submodule.  
2. Build libllama.dylib library.  

```
cd wrapper
make build
```

The lib will be placed in *wrapper/build/src/libllama.dylib*

3. Place some llama.cpp-compatible model, i.e. I use [city96/t5-v1_1-xxl-encoder-gguf](https://huggingface.co/city96/t5-v1_1-xxl-encoder-gguf).  
Make sure that path to model is correctly defined in llama.rkt.

```
Line 327: (define model (llama-load-model-from-file "./t5-v1_1-xxl-encoder-Q5_K_M.gguf" model-params))
```

4. Now you can use it with *llama.rkt*, run to test:

```
racket ./llama.rkt
```



# Tokenizer works now:

![tokenizer](./tokenizer.gif)
