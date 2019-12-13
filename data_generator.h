#include <ctime>
#include <iostream>
#include <stdlib.h>
void populate(int *array, int dim, bool print) {
  for (int i = 0; i < dim; i++) {

    array[i] = rand() % 1000;
    if (print)
      std::cout << array[i] << std::endl;
  }
  std::cout << std::endl;
}