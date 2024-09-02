llama_cpp_dir = ../llama.cpp
llama_h = $(llama_cpp_dir)/include/llama.h
llama_h_back = $(llama_cpp_dir)/include/llama.h.back
llama_cpp = $(llama_cpp_dir)/src/llama.cpp
llama_cpp_back = $(llama_cpp_dir)/src/llama.cpp.back
llama_h_wrapper = llama.h
llama_cpp_wrapper = llama.cpp
build_dir = "./build"
dylib = "./libllama.dylib"

backup-llama:
	cp $(llama_h) $(llama_h_back)
	cp $(llama_cpp) $(llama_cpp_back)

build: backup-llama
	mkdir $(build_dir)
	cd $(build_dir); cmake -DBUILD_SHARED_LIBS=ON ../$(llama_cpp_dir)
	cat $(llama_cpp_wrapper) >> $(llama_cpp)
	racket ./merge_llama_src.rkt $(llama_h_back) $(llama_h_wrapper) $(llama_h)
	cd build; make
	codesign -s - ./build/src/libllama.dylib

clean:
	-rm -r ./build/
	-rm $(dylib)
	cp $(llama_h_back) $(llama_h)
	cp $(llama_cpp_back) $(llama_cpp)

rebuild: clean build
