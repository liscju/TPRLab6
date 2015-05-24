#include <stdio.h>
#include <cuda.h>
#include <stdlib.h>
#include <time.h>
#include "helper_functions.h"

void init(int *a,int *b, int size) {
	int i;
	for (i=0; i<size; i++) {
		a[i] = i;
		b[i] = i;
	}
}

void add(int *a,int *b, int *c, int size) {
	int i;
	for(i=0; i<size; i++) {
		c[i] = a[i]+b[i];
	}
}


int main(int argc, char *argv[]) {
	if(argc != 2) {
		fprintf(stderr, "Wrong arguments. Usage: %s <vector-size>\n", argv[0]);
		return EXIT_FAILURE;
	}
	int vectorSize = atoi(argv[1]);


	int* a;
	int* b;
	int* c;

	a = (int*)malloc(vectorSize * sizeof(int));
	b = (int*)malloc(vectorSize * sizeof(int));
	c = (int*)malloc(vectorSize * sizeof(int));

	init(a, b, vectorSize);

	StopWatchInterface* timer = NULL;
	sdkCreateTimer(&timer);
	sdkResetTimer(&timer);
	sdkStartTimer(&timer);

	add(a, b, c, vectorSize);

	sdkStopTimer(&timer);
	float time = sdkGetTimerValue(&timer);
	sdkDeleteTimer(&timer);

	printf("%d+%d=%d\n", a[vectorSize-1], b[vectorSize-1], c[vectorSize-1]);

	printf("%d %f\n", vectorSize, time);

	free(a);
	free(b);
	free(c);
}
