llama_cpp_dir = ./vendor/llama.cpp
llama_h = $(llama_cpp_dir)/include/llama.h
llama_cpp = $(llama_cpp_dir)/src/llama.cpp
build_dir = "./build"
dylib = "./libllama.dylib"

update:
	git submodule update --init --recursive

update.vendor:
	cd vendor/llama.cpp && git pull origin master

build:
	mkdir $(build_dir)
	cd $(build_dir); cmake -DBUILD_SHARED_LIBS=ON ../$(llama_cpp_dir)
	cd build; make
	codesign -s - ./build/src/libllama.dylib
	cp ./build/src/libllama.dylib $(dylib)

clean:
	-rm -r ./build/
	-rm $(dylib)

rebuild: clean build
