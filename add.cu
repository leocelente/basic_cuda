// Simple ADD kernel to demonstrate the general pattern in C CUDA
// compile: nvcc -o add add.cu
#include "data_generator.h"
#include <cuda.h>
#include <iostream>
#define COUNT 100000

// KERNEL
__global__ void MainCUDAKernel(int *a, int *b) {
  int id = blockIdx.x * blockDim.x + threadIdx.x;
  a[id] *= b[id] + (a[id] % b[id]);
}

int main() {
  srand(time(NULL));
  // GENERATE & ALLOCATE DATA ON HOST
  int dim = COUNT;
  int size = sizeof(int) * dim;
  int h_a[COUNT];
  int h_b[COUNT];
  populate(h_a, dim, false);
  populate(h_b, dim, false);

  // ALLOCATE DATA ON DEVICE AND COPY
  int *d_a, *d_b;
  if (cudaMalloc(&d_a, size) != cudaSuccess) {
    std::cerr << "Failed: cudaMalloc d_a" << std::endl;
    return -1;
  };
  if (cudaMalloc(&d_b, size) != cudaSuccess) {
    cudaFree(d_a);
    std::cerr << "Failed: cudaMalloc d_b" << std::endl;
    return -1;
  };
  if (cudaMemcpy(d_a, &h_a, size, cudaMemcpyHostToDevice) != cudaSuccess) {
    cudaFree(d_a);
    cudaFree(d_b);
    std::cerr << "Failed: cudaMemcpy h_a" << std::endl;
    return -1;
  };
  if (cudaMemcpy(d_b, &h_b, size, cudaMemcpyHostToDevice) != cudaSuccess) {
    cudaFree(d_a);
    cudaFree(d_b);
    std::cerr << "Failed: cudaMemcpy h_b" << std::endl;
    return -1;
  };

  // CALL KERNEL
  //   dim (number of threads) must be < 1024
  MainCUDAKernel<<<(dim / 1024) + 1, 1024>>>(d_a, d_b);

  //   OUTPUT
  if (cudaMemcpy(&h_a, d_a, size, cudaMemcpyDeviceToHost) != cudaSuccess) {
    cudaFree(d_a);
    cudaFree(d_b);
    std::cerr << "Failed: cudaMemcpy d_a " << std::endl;
    return -1;
  };
  //   for (int i = 0; i < dim; i++)
  //     std::cout << "a[" << i << "] = " << h_a[i] << std::endl;

  //  CLEANUP
  cudaFree(d_a);
  cudaFree(d_b);

  return 0;
}