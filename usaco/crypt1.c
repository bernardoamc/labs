/*
ID: bernard8
LANG: C
TASK: crypt1
*/

#include <stdio.h>

/* Idéia, criar todas as combinações dos números fornecidos
 * e checar se o resultado da multiplicação contém apenas os
 * números fornecidos também.
*/

int main(void) {
  FILE *fin  = fopen ("crypt1.in", "r");
  FILE *fout = fopen ("crypt1.out", "w");


  fscanf (fin, "%d %d", &a, &b);  /* the two input integers */
  fprintf (fout, "Placeholder\n");

  return 0;
}
