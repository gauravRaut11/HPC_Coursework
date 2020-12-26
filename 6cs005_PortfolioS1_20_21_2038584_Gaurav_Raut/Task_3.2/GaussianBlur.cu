#include "lodepng.h"
#include <stdio.h>
#include <stdio.h>
#include <stdlib.h>

//compile with "nvcc GaussianBlur.cu loadpng.cpp -o gaussianBlur" 

__global__ void blurImage(unsigned char * newImage, unsigned char * image,unsigned int width,unsigned int height) {

	        int r = 0;
		int g = 0;
		int b = 0;
		int t = 0;
		int row,col;
		int count = 0;

		int idx = blockDim.x * blockIdx.x + threadIdx.x;
		int pixel = idx*4;

		for(row = (pixel - 4); row<=  (pixel + 4); row+=4){
			// Checking conditions so pixel is available at x
			if ((row > 0) && row < (height * width * 4) && ((row-4)/(4*width) == pixel/(4*width))){
				for(col = (row - (4 * width)); col <=  (row + (4 * width)); col+=(4*width)){
					if(col > 0 && col < (height * width * 4)){
						r += image[col];
						g += image[1+col];
						b += image[2+col]; 
						count++;
					}
				}
			}
		}
		
		t = image[3+pixel];

		newImage[pixel] = r / count;
		newImage[1+pixel] = g / count;
		newImage[2+pixel] = b / count;
		newImage[3+pixel] = t;
}
int time_difference(struct timespec *start,
 struct timespec *finish, 
  long long int *difference) {
  long long int ds =  finish->tv_sec - start->tv_sec; 
  long long int dn =  finish->tv_nsec - start->tv_nsec; 

  if(dn < 0 ) {
    ds--;
    dn += 1000000000; 
  } 
  *difference = ds * 1000000000 + dn;
  return !(*difference > 0);
}
int main(int argc, char **argv){
 struct timespec start, finish;

clock_gettime(CLOCK_MONOTONIC, &start);
clock_gettime(CLOCK_MONOTONIC, &finish);

long long int time_elapsed;
time_difference (&start, &finish, &time_elapsed);
printf("Time elapsed was %lldns or %0.9fs\n", time_elapsed, (time_elapsed/1.0e9));

	unsigned char* image;
	unsigned int width;
	unsigned int height;
	const char* filename = "hck.png";
	const char* newFileName = "output.png";

	lodepng_decode32_file(&image, &width, &height, filename);
	
        printf("Image width = %d height = %d\n", width, height);
	const int ARRAY_SIZE = width*height*4;
	const int ARRAY_BYTES = ARRAY_SIZE * sizeof(unsigned char);

	unsigned char host_imageInput[ARRAY_SIZE * 4];
	unsigned char host_imageOutput[ARRAY_SIZE * 4];

	for (int i = 0; i < ARRAY_SIZE; i++) {
		host_imageInput[i] = image[i];
	}

	// declare GPU memory pointers
	unsigned char * d_in;
	unsigned char * d_out;

	// allocate GPU memory
	cudaMalloc((void**) &d_in, ARRAY_BYTES);
	cudaMalloc((void**) &d_out, ARRAY_BYTES);

	cudaMemcpy(d_in, host_imageInput, ARRAY_BYTES, cudaMemcpyHostToDevice);

	// launch the kernel
	blurImage<<<height, width>>>(d_out, d_in, width,height);

	// copy back the result array to the CPU
	cudaMemcpy(host_imageOutput, d_out, ARRAY_BYTES, cudaMemcpyDeviceToHost);
	
	lodepng_encode32_file(newFileName, host_imageOutput, width, height);
	
	cudaFree(d_in);
	cudaFree(d_out);

	return 0;
}
