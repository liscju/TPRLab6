#include <cstdio>
#include <cuda.h>
#include <cstdlib>
#include "helper_functions.h"

__global__ void add (int *a,int *b, int *c,int N) 
{
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	if(tid < N) 
	{
		c[tid] = a[tid]+b[tid];
	}
}

void add_host(int *a,int *b,int *d,int N)
{
	int i;
	for (i = 0; i < N ; i ++ ) 
	{
		d[i] = a[i] + b[i];	
	}	
}

bool is_same(int *c,int *d,int N)
{
	bool same_tab = true;
	for (int i=0; i< N; i++ )
	{
		same_tab &= c[i] == d[i];
	}
	return same_tab;
}

void usage(void) {
	printf("Usage:\n./a.out size thread_per_block block_per_grid\n");
	exit(0);
}

int main(int argc,char **argv)
{
	if (argc != 4) {
		usage();
	}
	int *a,*b,*c,*d;
	int N = atoi(argv[1]);	
	int thread_per_block = atoi(argv[2]);
	int block_per_grid = atoi(argv[3]);
	a = (int*)malloc(N*sizeof(int));
	b = (int*)malloc(N*sizeof(int));
	c = (int*)malloc(N*sizeof(int));
	d = (int*)malloc(N*sizeof(int));

	for (int i=0;i<N;i++) 
	{
		a[i] = i;
		b[i] = i*1;
	}

	StopWatchInterface *timer = NULL;
	sdkCreateTimer(&timer);
	sdkResetTimer(&timer);
	sdkStartTimer(&timer);

	int *dev_a, *dev_b, *dev_c;
	cudaMalloc((void**)&dev_a,N * sizeof(int));
	cudaMalloc((void**)&dev_b,N * sizeof(int));
	cudaMalloc((void**)&dev_c,N * sizeof(int));
	cudaMemcpy(dev_a, a , N*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, b , N*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_c, c , N*sizeof(int),cudaMemcpyHostToDevice);
	add<<<block_per_grid,thread_per_block>>>(dev_a,dev_b,dev_c,N);
	cudaMemcpy(c,dev_c,N*sizeof(int),cudaMemcpyDeviceToHost);

	sdkStopTimer(&timer);
	float time = sdkGetTimerValue(&timer);
	sdkDeleteTimer(&timer);
	
	printf("----------Result for kernel----------\n");
	for (int i=0;i<N;i++) 
	{
		printf("%d+%d=%d\n",a[i],b[i],c[i]);
	}
	printf("Time for the kernel: %f ms\n",time);	

	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);

// Host part

	add_host(a,b,d,N);
	printf("----------Result for host:-----------\n");
	for (int i=0;i<N;i++)
	{
		printf("%d+%d=%d\n",a[i],b[i],d[i]);
	}

// Checking if same
	bool same_host_gpu = is_same(c,d,N);
	if (same_host_gpu) 
		printf("Same result for host and kernel\n");
	else
		printf("Different result for host and kernel\n");	

// Happy end
	return 0;
}
