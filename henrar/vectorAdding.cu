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
	const int dimension = 6;
	const int threads[dimension] = { 32, 64, 128, 256, 512, 1024 };
	const int blocks[dimension] = { 128, 256, 512, 1024, 2048, 4096 };
	const int sizes[dimension] = { 10000, 100000, 1000000, 10000000, 100000000, 1000000000 };

	StopWatchInterface *timer = NULL;
	float elapsedTime = 0.0f;
	
	std::ofstream resultsFile;
	resultsFile.open("results.txt");

	int N = 0;
	int * a;
	int * b;
	int * c;

	int threadId = 0;
	int block = 0;
	int *dev_a, *dev_b, *dev_c;
	cudaEvent_t start, stop;

	for (int sizeLoop = 0; sizeLoop < dimension; sizeLoop++)
	{
		N = sizes[sizeLoop];
		a = new int[N];
		b = new int[N];
		c = new int[N];
		for (int i = 0; i < dimension; i++)
		{
			threadId = threads[i];
			for (int x = 0; x < dimension; x++)
			{
				block = blocks[x];

				cudaMalloc((void**)&dev_a, N * sizeof(int));
				cudaMalloc((void**)&dev_b, N * sizeof(int));
				cudaMalloc((void**)&dev_c, N * sizeof(int));
				for (int j = 0; j < N; j++)
				{
					a[j] = j;
					b[j] = j * 1;
				}

		
				cudaMemcpy(dev_a, a, N*sizeof(int), cudaMemcpyHostToDevice);
				cudaMemcpy(dev_b, b, N*sizeof(int), cudaMemcpyHostToDevice);
				cudaMemcpy(dev_c, c, N*sizeof(int), cudaMemcpyHostToDevice);
				
				sdkCreateTimer(&timer);
				checkCudaErrors(cudaEventCreate(&start));
				checkCudaErrors(cudaEventCreate(&stop));
				checkCudaErrors(cudaEventRecord(start, 0));

				add << <block, threadId >> >(dev_a, dev_b, dev_c, N);

				checkCudaErrors(cudaEventRecord(stop, 0));
				checkCudaErrors(cudaDeviceSynchronize());
				sdkStopTimer(&timer);
				checkCudaErrors(cudaEventElapsedTime(&elapsedTime, start, stop));
				
				cudaMemcpy(c, dev_c, N*sizeof(int), cudaMemcpyDeviceToHost);

				resultsFile << N << " " << elapsedTime << " " << block * threadId << std::endl;
				cudaFree(dev_a);
				cudaFree(dev_b);
				cudaFree(dev_c);
			}
		}
		delete[] a;
		delete[] b;
		delete[] c;
	}
	resultsFile.close();
	std::cin.get();
	std::cin.ignore();
	return 0;
}
