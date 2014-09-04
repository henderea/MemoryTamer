#include <stdlib.h>
#include <math.h>
#include <stdio.h>

int main (int argc, char * argv[]) {
	if(argc <2){
		printf("Must specify size in bytes\n");
		return 1;
	}
	
	// allows full memory space usage
	long long size, i, ints;

	printf("argc: %d\n", argc);

	printf("argv[0]: '%s'\n", argv[0]);
	printf("argv[1]: '%s'\n", argv[1]);
	
	// size in bytes
	//size = 1024*1024*1024;
	size = strtoll(argv[1], NULL, 10);
	// caluclate the number of unsigned ints this will occupy
	ints = size / sizeof(unsigned int);
	// give a nice value printout
	printf("Allocating %lld bytes (%lld ints)\n", size, ints);
	
	// allocate the memory
	unsigned int* mem;
	mem = (unsigned int*) malloc(size);
	
	// in OS X you have to use it for it to count
	for (i=0; i<ints; i++) {
		mem[i] = rand();
	}
	
	// free it up. 
	free(mem);
	
	
	
	
//	int size;
//	int* mem;
//	//int i;
//	//ofstream rand;
//
//    //insert code here...
//    //
//	
//	size = 100000*4096;
//	
//	// alocate memory
//	mem = (int*) malloc(size);
//	int* i;
//	for (i = mem; i < size+mem; i++) {
//		*i = 
//	}
//	//rand.open("/dev/random".c_str(), ios::binary);
//	//rand.read(mem, size);
//	//rand.close();
//	
//	std::cout << mem;
//	free(mem);
    return 0;
}
