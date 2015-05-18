/*
ID: bernard8
LANG: C
TASK: barn1
*/

/*
  A idéia aqui foi contabilizar o numero de gaps e o tamanho dos mesmos.
  Ordenar e excluir os maiores dado o numero de boards.
*/

#include <stdio.h>
#include <stdlib.h>

#define MAX_STALLS 201

int blocked(FILE *, int, int, int);
int compareGap (const void *, const void *);

int main(void) {
  FILE *fin  = fopen ("barn1.in", "r");
  FILE *fout = fopen ("barn1.out", "w");
  int boards, stalls, cows;

  fscanf (fin, "%d %d %d ", &boards, &stalls, &cows);

  fprintf (fout, "%d\n", blocked(fin, boards, stalls, cows));

  return 0;
}

int blocked(FILE *fin, int boards, int stalls, int cows) {
  int positions[MAX_STALLS] = {0};
  int gaps[MAX_STALLS/2] = {0};
  int startedAt, stoppedAt, currentGap, inGap, i, groups, blocks = 0;

  if (boards >= cows) {
    return cows;
  }

  for (i = 0; i < cows; i++) {
    fscanf(fin, "%d ", &inGap);
    positions[inGap] = 1;
  }

  startedAt = 1;
  stoppedAt = stalls;

  while (!positions[startedAt]) {
    startedAt++;
  };

  while (!positions[stoppedAt]) {
    stoppedAt--;
  }

  i = startedAt;
  currentGap = -1;
  inGap = 0;

  while (i++ < stoppedAt) {
    if (!positions[i]) {
      if (!inGap) {
        inGap = 1;
        currentGap++;
      }

      gaps[currentGap]++;
    } else {
      inGap = 0;
    }
  }

  currentGap++;

  qsort(gaps, currentGap, sizeof(int), compareGap);
  groups = currentGap + 1;

  if (boards >= groups) {
    return cows;
  }

  blocks = cows;

  for (i = 0; i < (groups - boards); i++) {
    blocks += gaps[i];
  }

  return blocks;
}

int compareGap (const void *a, const void *b)
{
   return ( *(int*)a - *(int*)b );
}
