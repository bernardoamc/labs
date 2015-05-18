#include <stdlib.h>
#include <stdio.h>
#include "dbg.h"

int main(int argc, char *argv[])
{
  char **opa;

  opa = malloc(sizeof(char *) * 3);
  *(opa++) = malloc(sizeof(char) * 3);
  *(opa++) = malloc(sizeof(char) * 3);
  *(opa) = malloc(sizeof(char) * 3);

   *(opa--) = "oi";
   *(opa--) = "oi";
   *(opa) = "oi";

  printf("%s\n", *(opa++));
  printf("%s\n", *(opa++));
  printf("%s\n", *(opa));

  return 0;
}
