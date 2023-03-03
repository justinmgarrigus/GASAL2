#!/bin/bash

# ./configure.sh /usr/local/cuda-11.7 

sm_version=70
base_path="/usr/local/cuda"

lib_path="$base_path/lib64"
include_path="$base_path/include"

set -x 

mkdir -p obj 
mkdir -p lib 
mkdir -p include 
cp src/*.h include

g++  -c -L${lib_path} -I${include_path} -DMAX_QUERY_LEN=160 -DN_CODE=0x4E src/args_parser.cpp -o ./obj/args_parser.cppo -lcudart 
g++  -c -L${lib_path} -I${include_path} -DMAX_QUERY_LEN=160 -DN_CODE=0x4E src/host_batch.cpp -o ./obj/host_batch.cppo -lcudart 
g++  -c -L${lib_path} -I${include_path} -DMAX_QUERY_LEN=160 -DN_CODE=0x4E src/ctors.cpp -o ./obj/ctors.cppo -lcudart 
g++  -c -L${lib_path} -I${include_path} -DMAX_QUERY_LEN=160 -DN_CODE=0x4E src/interfaces.cpp -o ./obj/interfaces.cppo -lcudart 
g++  -c -L${lib_path} -I${include_path} -DMAX_QUERY_LEN=160 -DN_CODE=0x4E src/res.cpp -o ./obj/res.cppo -lcudart 
nvcc -dc -keep -o ./obj/gasal_align.o -L${lib_path} -I${include_path} -DMAX_QUERY_LEN=160 -DN_CODE=0x4E -arch=sm_${sm_version} src/gasal_align.cu
nvcc -dlink -keep -o ./obj/gasal_align_link.o -L${lib_path} -I${include_path} obj/gasal_align.o -DMAX_QUERY_LEN=160 -DN_CODE=0x4E -arch=sm_${sm_version}
ar -src ./lib/libgasal.a ./obj/args_parser.cppo ./obj/host_batch.cppo ./obj/ctors.cppo ./obj/interfaces.cppo ./obj/res.cppo ./obj/gasal_align.o ./obj/gasal_align_link.o

### test, with archive
# g++ -c -fopenmp -Iinclude -o test_prog.o test_prog/test_prog.cpp 
# g++ -o test_prog.out -L${lib_path} -I${include_path} -Llib test_prog.o -lgasal -fopenmp -lcudart 

### simple, with archive 
# g++ -c -fopenmp -Iinclude -o test_prog.o simple.cpp 
# g++ -o test_prog.out -L${lib_path} -I${include_path} -Llib test_prog.o -fopenmp -lcudart -lgasal

### test, no archive  
g++ -c -fopenmp -Iinclude -o test_prog.o test_prog/test_prog.cpp 
g++ -o test_prog.out -L${lib_path} -I${include_path} obj/args_parser.cppo obj/host_batch.cppo obj/ctors.cppo obj/interfaces.cppo obj/res.cppo obj/gasal_align.o obj/gasal_align_link.o test_prog.o -lcudadevrt -fopenmp -lcudart

### simple, no archive
# g++ -c -fopenmp -Iinclude -o simple.o simple.cpp 
# g++ -o test_prog.out -L${lib_path} -I${include_path} obj/args_parser.cppo obj/host_batch.cppo obj/ctors.cppo obj/interfaces.cppo obj/res.cppo obj/gasal_align.cuo simple.o -fopenmp -lcudart
