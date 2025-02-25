#!/bin/bash


cuda_path=$1
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ "$cuda_path" = "" ]; then
  echo -e "${RED}Must provide path to CUDA installation directory${NC}"
  echo -e "${RED}Configuration incomplete${NC}"
  echo -e "${RED}Exiting${NC}"	
  exit 1	
fi	

cuda_nvcc_path=$cuda_path/bin/nvcc

if [ -f $cuda_nvcc_path ]; then
 echo "NVCC found ($cuda_nvcc_path)"
else
  echo -e "${RED}NVCC not found${NC}"
  echo -e "${RED}Configuration incomplete${NC}"
  echo -e "${RED}Exiting${NC}"	
  exit 1	
fi	


cuda_lib_path="$(dirname $(find ${cuda_path} -name 'libcudadevrt.a' -type f))"


if [ -d $cuda_lib_path ]; then
 echo "CUDA runtime library found (${cuda_lib_path})"
else
  echo -e "${RED}CUDA runtime library not found${NC}" 
  echo -e "${RED}Configuration incomplete${NC}"
  echo -e "${RED}Exiting${NC}"
  exit 1	
fi

# cuda_runtime_file="${cuda_path}/targets/x86_64-linux/include/cuda_runtime.h"
cuda_runtime_file="$(find ${cuda_path} -name 'cuda_runtime.h' -type f)"

if [ -f $cuda_runtime_file ]; then
 echo  "CUDA runtime header file found (${cuda_runtime_file})"
else
  echo -e "${RED}CUDA runtime header file not found${NC}"
  echo -e "${RED}Configuration incomplete${NC}"
  echo -e "${RED}Exiting${NC}"
  exit 1	
fi


echo "Configuring Makefile..."

sed  -i "s,NVCC=.*,NVCC=$cuda_nvcc_path,g" Makefile 

echo "Configuring gasal.h..."

sed  -i "s,.*cuda_runtime\.h\",\#include \"$cuda_runtime_file\",g" ./src/gasal.h

echo "Configuring Makefile of test program..."

sed  -i "s,CUDA_LD_LIBRARY=.*,CUDA_LD_LIBRARY=$cuda_lib_path,g" ./test_prog/Makefile 

#mkdir -p include

#cp ./src/gasal.h ./include

echo "Done"


