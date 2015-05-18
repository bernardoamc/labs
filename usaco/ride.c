/*
ID: bernard8
LANG: C
TASK: ride
*/

#include <stdio.h>

int main(void) {
  FILE *fin  = fopen ("ride.in", "r");
  FILE *fout = fopen ("ride.out", "w");
  char comet[7], group[7];
  int i, mod1, mod2;

  mod1 = mod2 = 1;

  fscanf(fin, "%s", comet);
  fscanf(fin, "%s", group);

  for (i = 0; i < 6; i++) {
    mod1 *= ((comet[i] >= 'A' && comet[i] <= 'Z') ? (comet[i] - 'A' + 1) : 1);
    mod2 *= ((group[i] >= 'A' && group[i] <= 'Z') ? (group[i] - 'A' + 1) : 1);
  }

  if ((mod1 % 47) == (mod2 % 47)) {
    fprintf(fout, "GO\n");
  } else {
    fprintf(fout, "STAY\n");
  }

  return 0;
}
