#include <stdio.h>
#include <cuda.h>
#include <cstdlib>
#include "helper_functions.h"

#define MY_CPU 0
#define MY_GPU 1

// GLOBALS
int type;
int vectorSize;
int blockCount;
int threadCount;
	
int* a;
int* b;
int* c;
// END GLOBALS

void init(int *a, int *b, int size) {
	int i;
	for (i=0; i<size; i++) {
		a[i] = i;
		b[i] = i;
	}
}

__global__ void add(int *a,int *b, int *c, int size) {
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	if(tid < size) {
		c[tid] = a[tid] + b[tid];
	}
}

void addCPU(int *a,int *b, int *c, int size) {
	int i;
	for(i=0; i<size; i++) {
		c[i] = a[i]+b[i];
	}
}

void countCPU() {
	printf("###CPU:\n %d %d", vectorSize, blockCount);
	StopWatchInterface* timer = NULL;
	sdkCreateTimer(&timer);
	sdkResetTimer(&timer);
	sdkStartTimer(&timer);
	
	addCPU(a, b, c, vectorSize);
	
	sdkStopTimer(&timer);
	float time = sdkGetTimerValue(&timer);
	sdkDeleteTimer(&timer);
	
	printf("%d+%d=%d\n", a[vectorSize-1], b[vectorSize-1], c[vectorSize-1]);
	printf("%d %f\n", vectorSize, time);
}

void countGPU() {
	printf("###GPU:\n %d %d", vectorSize, blockCount);
	int *dev_a, *dev_b, *dev_c;
	cudaMalloc((void**)&dev_a, vectorSize * sizeof(int));
	cudaMalloc((void**)&dev_b, vectorSize * sizeof(int));
	cudaMalloc((void**)&dev_c, vectorSize * sizeof(int));
	
	cudaMemcpy(dev_a, a, vectorSize * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, b, vectorSize * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_c, c, vectorSize * sizeof(int), cudaMemcpyHostToDevice);
	
	StopWatchInterface* timer = NULL;
	sdkCreateTimer(&timer);
	sdkResetTimer(&timer);
	sdkStartTimer(&timer);

	add<<<blockCount,threadCount>>>(dev_a, dev_b, dev_c, vectorSize);
	cudaThreadSynchronize();
	
	sdkStopTimer(&timer);
	float time = sdkGetTimerValue(&timer);
	sdkDeleteTimer(&timer);

	cudaMemcpy(c, dev_c, vectorSize * sizeof(int), cudaMemcpyDeviceToHost);
	
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);
	
	printf("%d+%d=%d\n", a[vectorSize-1], b[vectorSize-1], c[vectorSize-1]);
	printf("%d %f\n", vectorSize, time);
}

int main(int argc, char** argv) {
	if(argc != 4) {
		fprintf(stderr, "Wrong arguments. Usage: %s <vector-size> <block-count> <thread-count>\n", argv[0]);
		return EXIT_FAILURE;
	}
	int vectorSize = atoi(argv[1]);
	int blockCount = atoi(argv[2]);
	int threadCount = atoi(argv[3]);
	
	int* a;
	int* b;
	int* c;

	a = (int*)malloc(vectorSize * sizeof(int));
	b = (int*)malloc(vectorSize * sizeof(int));
	c = (int*)malloc(vectorSize * sizeof(int));

	init(a, b, vectorSize);
	
	countGPU();
	countCPU();

	free(a);
	free(b);
	free(c);	

	return EXIT_SUCCESS;
}


