#include <cuda.h>
#include <cstdlib>
#include <iostream>
#include <cstdio>
#include "helper_functions.h"
#include "helper_cuda.h"

__global__ void add (int *a,int *b, int *c, const int N) 
{
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	if(tid < N) 
	{
		c[tid] = a[tid]+b[tid];
	}
}

int main(void)
{
	StopWatchInterface *timer = NULL;
	float elapsedTime = 0.0f;

	int tableSize = 0;
	std::cout << "Podaj rozmiar tablicy: ";
	std::cin >> tableSize;
	std::cout << std::endl;	
	
	int N = tableSize;

	int a[N],b[N],c[N];
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
	add<<<1,N>>>(dev_a,dev_b,dev_c, N);
	cudaMemcpy(c,dev_c,N*sizeof(int),cudaMemcpyDeviceToHost);
	checkCudaErrors(cudaEventRecord(stop, 0));
	checkCudaErrors(cudaDeviceSynchronize());
	sdkStopTimer(&timer);
	checkCudaErrors(cudaEventElapsedTime(&elapsedTime, start, stop));
	for (int i=0;i<N;i++) 
	{
		printf("%d+%d=%d\n",a[i],b[i],c[i]);
	}
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);
	std::cout << "Elapsed time: " << elapsedTime << std::endl;
	return 0;
}
