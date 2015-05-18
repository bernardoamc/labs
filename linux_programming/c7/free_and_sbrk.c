/*
  This program was created to demonstrate that malloc() does not calls
  sbrk() to adjust the program break on each call, but instead periodically
  allocates larger chunks of memory from which it passes back small pieces
  to the caller.

  Usage: free_and_sbrk num-allocs block-size [step [min [max]]]

  Examples: free_and_sbrk 1000 10240 2 1 1000
            free_and_sbrk 1000 10240 1 1 999
            free_and_sbrk 1000 10240 1 500 1000
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define MAX_ALLOCS 1000000

void failure(const char *message);
void usage(const char *program_name);
int to_integer(const char *param);

int main(int argc, char *argv[]) {
  char *ptr[MAX_ALLOCS];
  int freeStep, freeMin, freeMax, blockSize, numAllocs, j;

  if (argc < 3 || strcmp(argv[1], "--help") == 0) {
    usage(argv[0]);
  }

  numAllocs = to_integer(argv[1]);

  if (numAllocs > MAX_ALLOCS) {
    failure("num-allocs exceeds maximum allocation");
  }

  blockSize = to_integer(argv[2]);

  freeStep = (argc > 3) ? to_integer(argv[3]) : 1;
  freeMin  = (argc > 4) ? to_integer(argv[4]) : 1;
  freeMax  = (argc > 5) ? to_integer(argv[5]) : numAllocs;

  if (freeMax > numAllocs) {
    failure("free-max exceeds the number of allocations");
  }

  printf("Initial program break: %10p\n", sbrk(0));
  printf("Allocating %d*%d bytes\n\n", numAllocs, blockSize);

  for (j = 0; j < numAllocs; j++) {
    ptr[j] = malloc(blockSize);
    printf("Current program break: %10p\n", sbrk(0));

    if (ptr[j] == NULL) {
      failure("malloc");
    }
  }

  printf("\nFreeing blocks from %d to %d in steps of %d\n", freeMin, freeMax, freeStep);

  for (j = freeMin - 1; j < freeMax; j += freeStep) {
    free(ptr[j]);
  }

  printf("After free(), program break is: %10p\n", sbrk(0));

  exit (EXIT_SUCCESS);
}

void failure(const char *message) {
  printf("%s\n", message);
  exit(EXIT_FAILURE);
}

void usage(const char *program_name) {
  printf("%s num-allocs block-size [step [min [max]]]\n", program_name);
  exit(EXIT_FAILURE);
}

int to_integer(const char *param) {
  int num = 0;
  char **str = NULL;

  num = strtol(param, str, 10);

  if (str != NULL || num <= 0) {
    failure("every parameter must be an integer greater than zero");
  }

  return num;
}
