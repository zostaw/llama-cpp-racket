# llama.cpp over FFI into Racket

This repository contains hand-made bindings for some of the functions from llama.h, allowing to use it with FFI.  
I am not planning to maintain it, in the near future, it serves purely practical purpose for my other project.  
But please feel free to use it if you like :) and if you wanna add something, let me know.  
  
It assumes .dylib is used, so it's tested on MacOS only, but I'm pretty sure it could work with other architectures, too. 
The only requirement would be to update *build* section in Makefile accordingly.  


It was last tested with [llama.cpp release b3756](https://github.com/ggerganov/llama.cpp/releases/tag/b3756),
but I suspect it will work with any version.  


# What does it contain

Once you build the project, you can get rid of everything apart from:  
- *libllama.dylib* - main dependency, containing llama.cpp code  
- *racket.rkt* - contains the bindings that allow to call functions from above library  

The examples show how you can incorporate it with your project.  


# Usage

1. Initialize *llama.cpp* submodule:  

```
make update
```

2. Build *libllama.dylib* library:  

```
make build
```

If you changed something in llama.cpp source code (or updated submodule again) and want to rebuild, use this:  

```
make rebuild
```

it can be executed multiple times. It basically clears the state and builds libllama again.  
  
  
The lib will be placed in main directory as *libllama.dylib*  

3. Download a llama.cpp compatible model, for instance I use [city96/t5-v1_1-xxl-encoder-gguf](https://huggingface.co/city96/t5-v1_1-xxl-encoder-gguf).  
Make sure that path to model is correctly defined in your llama program, for instance in *example-tokenizer.rkt*.  
In the example I use *model.gguf* for simplicity.  

```
Line 35: (define model-path (path->complete-path "model.gguf"))
```

4. Now you can use it with *llama.rkt*, run to test:

```
racket ./example-tokenizer.rkt
```

![tokenizer](./example-tokenizer.gif)

```
racket ./example-batch-initialization.rkt
```

![batch initialization](./example-batch-initialization.gif)


