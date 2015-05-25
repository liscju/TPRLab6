#!/bin/sh
nvcc vectorAdding.cu -o vectorAdding.out -gencode arch=compute_20,code=sm_20
./vectorAdding.out