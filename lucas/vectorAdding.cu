#include <stdio.h>
#include <cuda.h>
#include <cstdlib>

__global__ void add (int *a,int *b, int *c, int size) {
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	if(tid < size) {
		c[tid] = a[tid]+b[tid];
	}
}

int main(int argc, char** argv) {
	if(argc != 2) {
		fprintf(stderr, "Wrong arguments. Usage: %s <vector-size>\n", argv[0]);
		return EXIT_FAILURE;
	}
	int N = atoi(argv[1]);
	
	int* a;
	int* b;
	int* c;

	a = malloc(N*sizeof(int));
	b = malloc(N*sizeof(int));
	c = malloc(N*sizeof(int));

	int *dev_a, *dev_b, *dev_c;
	cudaMalloc((void**)&dev_a,N * sizeof(int));
	cudaMalloc((void**)&dev_b,N * sizeof(int));
	cudaMalloc((void**)&dev_c,N * sizeof(int));
	for (int i=0;i<N;i++) {
		a[i] = i;
		b[i] = i*1;
	}
	cudaMemcpy(dev_a, a , N*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, b , N*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_c, c , N*sizeof(int),cudaMemcpyHostToDevice);
	add<<<1,N>>>(dev_a,dev_b,dev_c, N);
	cudaMemcpy(c,dev_c,N*sizeof(int),cudaMemcpyDeviceToHost);
	for (int i=0;i<N;i++) {
		printf("%d+%d=%d\n",a[i],b[i],c[i]);
	}
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);

	free(a);
	free(b);
	free(c);	

	return 0;
}
