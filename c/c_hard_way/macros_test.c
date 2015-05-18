#include <stdio.h>

#define PRINT(A) { printf("%s\n", (A)); }

#define PRINT_5 { \
  PRINT("hi");    \
  PRINT("hi");    \
  PRINT("hi");    \
  PRINT("hi");    \
  PRINT("hi");    \
}

#define PRINT_N(N) { \
  int a = (N);       \
  do {               \
    PRINT("HI");     \
  } while(--a);       \
}

int main(int argc, char *argv[])
{
  PRINT_5
  PRINT_N(5)
  return 0;
}
