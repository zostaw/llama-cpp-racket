llama_cpp_dir = ../llama.cpp
llama_h = $(llama_cpp_dir)/include/llama.h
llama_c = $(llama_cpp_dir)/src/llama.c
build_dir = "./build"
dylib = "./libllama.dylib"

backup-llama:
	cp $(llama_h) $(llama_h).back
	cp $(llama_c) $(llama_c).back

build: backup-llama
	mkdir $(build_dir)
	cd $(build_dir); cmake -DBUILD_SHARED_LIBS=ON ../$(llama_cpp_dir)
	#cd build; make

clean:
	-rm -r ./build/
	-rm $(dylib)
	cp $(llama_h).back $(llama_h)
	cp $(llama_c).back $(llama_c)
