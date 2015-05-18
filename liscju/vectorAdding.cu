#include <cstdio>
#include <cuda.h>
#include <cstdlib>

__global__ void add (int *a,int *b, int *c,int N) 
{
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	if(tid < N) 
	{
		c[tid] = a[tid]+b[tid];
	}
}

void usage(void) {
	printf("Usage:\n./a.out size\n");
	exit(0);
}

int main(int argc,char **argv)
{
	if (argc < 2) {
		usage();
	}
	int *a,*b,*c;
	int N = atoi(argv[1]);	
	a = (int*)malloc(N*sizeof(int));
	b = (int*)malloc(N*sizeof(int));
	c = (int*)malloc(N*sizeof(int));

	int *dev_a, *dev_b, *dev_c;
	cudaMalloc((void**)&dev_a,N * sizeof(int));
	cudaMalloc((void**)&dev_b,N * sizeof(int));
	cudaMalloc((void**)&dev_c,N * sizeof(int));
	for (int i=0;i<N;i++) 
	{
		a[i] = i;
		b[i] = i*1;
	}
	cudaMemcpy(dev_a, a , N*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, b , N*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_c, c , N*sizeof(int),cudaMemcpyHostToDevice);
	add<<<1,N>>>(dev_a,dev_b,dev_c,N);
	cudaMemcpy(c,dev_c,N*sizeof(int),cudaMemcpyDeviceToHost);
	for (int i=0;i<N;i++) 
	{
		printf("%d+%d=%d\n",a[i],b[i],c[i]);
	}
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);
	return 0;
}
