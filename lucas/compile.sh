#!/bin/sh

#cpu


#gpu
module add gpu/cuda
nvcc bandwidthTest.cu -o b.out -gencode arch=compute_20,code=sm_20
nvcc deviceQuery.cu -o d.out -gencode arch=compute_20,code=sm_20
