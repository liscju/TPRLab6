#include <cstdio>
#include <cstdlib>
#include <ctime>
#include "helper_functions.h"
#include <fstream>

void init(int *a,int *b, int size) 
{
	int i;
	for (i=0; i<size; i++) 
	{
		a[i] = i;
		b[i] = i;
	}
}

void add(int *a,int *b, int *c, int size) 
{
	int i;
	for(i=0; i<size; i++) 
	{
		c[i] = a[i]+b[i];
	}
}


int main(int argc, char *argv[]) 
{
	const int dimension = 6;
	const int sizes[dimension] = { 10000, 100000, 1000000, 10000000, 100000000, 1000000000 };
	int* a;
	int* b;
	int* c;
	int vectorSize;		
	StopWatchInterface* timer = NULL;
	std::ofstream resultsFile;
	resultsFile.open("results.txt");
	for (int x = 0; x < dimension; x++)
	{
		vectorSize = sizes[x];

		a = (int*)malloc(vectorSize * sizeof(int));
		b = (int*)malloc(vectorSize * sizeof(int));
		c = (int*)malloc(vectorSize * sizeof(int));

		init(a, b, vectorSize);


		sdkCreateTimer(&timer);
		sdkResetTimer(&timer);
		sdkStartTimer(&timer);

		add(a, b, c, vectorSize);

		sdkStopTimer(&timer);
		float time = sdkGetTimerValue(&timer);
		sdkDeleteTimer(&timer);

		printf("%d+%d=%d\n", a[vectorSize - 1], b[vectorSize - 1], c[vectorSize - 1]);

		printf("%d %f\n", vectorSize, time);

		resultsFile << vectorSize << " " << time << std::endl;

		free(a);
		free(b);
		free(c);
	}
	resultsFile.close();
	return 0;
}
