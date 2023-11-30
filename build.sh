#!/bin/bash
mkdir -p build
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../wasi-toolchain.cmake ..
make