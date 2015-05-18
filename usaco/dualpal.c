/*
ID: bernard8
LANG: C
TASK: dualpal
*/

#include <stdio.h>
#include <math.h>

int main(void) {
  FILE *fin  = fopen ("dualpal.in", "r");
  FILE *fout = fopen ("dualpal.out", "w");

  int base, matches, limit, start_from, i;
  int rest, left, reversed;

  if (!(fscanf(fin, "%d %d", &limit, &start_from) == 2)) {
    return 1;
  }

  for (i = start_from + 1; i < 2147483647 && limit > 0; ++i) {
    matches = 0;

    for(base = 2; base <= 10 && matches < 2; ++base) {
      left = i;
      reversed = 0;

      while(left > 0) {
        rest = left % base;
        reversed = (reversed * base) + rest;
        left = left / base;
      }

      if (i == reversed) {
        matches++;
      }
    }

    if (matches >= 2) {
      fprintf(fout, "%d\n", i);
      limit--;
    }
  }

  return 0;
}
