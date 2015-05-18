/*
ID: bernard8
LANG: C
TASK: calfflac
*/

#include <stdio.h>
#include <stdlib.h>

#define MAX 20000

#define IS_LETTER(c) ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z'))

#define EQUAL(x, y) ((x == y || (x + 32) == y || (x - 32) == y))

char string[MAX] = {'\0'};
char cleaned[MAX] = {'\0'};

int main(void) {
  FILE *fin  = fopen ("calfflac.in", "r");
  FILE *fout = fopen ("calfflac.out", "w");
  int c, max, current, start, end, init;
  int startCleaned, endCleaned, trackOriginal, endTemp;

  trackOriginal = endCleaned = startCleaned = end = init = start = 0;
  max = 1;

  while ((c = fgetc(fin)) != EOF) {
    string[end++] = c;
    if(IS_LETTER(c)) cleaned[endCleaned++] = c;
  }

  end--;
  endCleaned--;

  while(startCleaned <= endCleaned) {
    endTemp = endCleaned;

    while (startCleaned <= endTemp) {
      current = 1;
      start = startCleaned;

      while (endTemp >= start && !EQUAL(cleaned[start], cleaned[endTemp])) {
        endTemp--;
      }

      while(endTemp >= start) {
        if (!EQUAL(cleaned[start], cleaned[endTemp])) {
          current = 0;
          break;
        }

        if (start < endTemp) {
          current += 2;
        } else {
          current++;
        }

        start++;
        endTemp--;
      }

      if (current) {
        break;
      }
    }

    if (current > max) {
      max = current;
      init = startCleaned;

      if (max >= (endCleaned - startCleaned)) break;
    }

    startCleaned++;
  }

  // Find the actual position in the string
  while(init >= 0) {
    if(IS_LETTER(string[trackOriginal])) init--;
    trackOriginal++;
  }

  trackOriginal--;

  fprintf(fout, "%d\n", max - 1);

  current = trackOriginal + max - 1;

  while(trackOriginal < current && trackOriginal <= end) {
    if (!IS_LETTER(string[trackOriginal])) current++;

    fprintf(fout, "%c", string[trackOriginal++]);
  }

  fprintf(fout, "\n");

  return 0;
}
