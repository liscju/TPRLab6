#include <cuda.h>
#include <cstdlib>
#include <iostream>
#include <cstdio>
#include "helper_functions.h"
#include "helper_cuda.h"
#include <fstream>



void doStuffOnCPU() //does stuff on CPU
{

}


__global__ void add (int *a,int *b, int *c, const int N) 
{
	long long int tid = blockIdx.x * blockDim.x + threadIdx.x;
	if(tid < N) 
	{
		c[tid] = a[tid]+b[tid];
	}
}

int main(int argc, char** argv)
{
	if (argc != 2) {
		fprintf(stderr, "Wrong arguments. \n", argv[0]);
		std::cin.get();
		std::cin.ignore();
		return EXIT_FAILURE;
	}
	StopWatchInterface *timer = NULL;
	float elapsedTime = 0.0f;
	
	
	int threadId = 1024;
	int block = 65535;

	char * tempTableSize = argv[1];
	unsigned int tableSize = *tempTableSize - '0'; //that shit is dirty
	
	int N = tableSize;

	int * a = new int[N];
	int * b = new int[N];
	int * c = new int[N];

	int *dev_a, *dev_b, *dev_c;
	cudaMalloc((void**)&dev_a,N * sizeof(int));
	cudaMalloc((void**)&dev_b,N * sizeof(int));
	cudaMalloc((void**)&dev_c,N * sizeof(int));
	for (int i=0;i<N;i++) 
	{
		a[i] = i;
		b[i] = i*1;
	}

	cudaEvent_t start, stop;
	sdkCreateTimer(&timer);
	checkCudaErrors(cudaEventCreate(&start));
	checkCudaErrors(cudaEventCreate(&stop));

	checkCudaErrors(cudaEventRecord(start, 0));
	cudaMemcpy(dev_a, a , N*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, b , N*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_c, c , N*sizeof(int),cudaMemcpyHostToDevice);
	
	add<<<block,threadId>>>(dev_a, dev_b, dev_c, N);
	
	cudaMemcpy(c,dev_c,N*sizeof(int),cudaMemcpyDeviceToHost);
	checkCudaErrors(cudaEventRecord(stop, 0));
	checkCudaErrors(cudaDeviceSynchronize());
	sdkStopTimer(&timer);
	checkCudaErrors(cudaEventElapsedTime(&elapsedTime, start, stop));


	//print stuff in format:
	//"%d %f", size, time
	/*for (int i=0;i<N;i++) 
	{
		printf("%d+%d=%d\n",a[i],b[i],c[i]);
	}*/

	std::cout << "Program finished in time: " << elapsedTime << std::endl;
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);

	std::cin.get();
	std::cin.ignore();
	return 0;
}
