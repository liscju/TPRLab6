#!/bin/sh
module add gpu/cuda
nvcc bandwidthTest.cu -o b.out -gencode arch=compute_20,code=sm_20
nvcc deviceQuery.cu -o d.out -gencode arch=compute_20,code=sm_20
nvcc vectorAdding.cu -o v.out -gencode arch=compute_20,code=sm_20
