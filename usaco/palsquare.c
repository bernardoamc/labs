/*
ID: bernard8
LANG: C
TASK: palsquare
*/

#include <stdio.h>
#include <math.h>

char numbers[20] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'};

void convert(int, int, char []);

int main(void) {
  FILE *fin  = fopen ("palsquare.in", "r");
  FILE *fout = fopen ("palsquare.out", "w");

  int base, i, squared;
  int rest, left, reversed;
  char num[9], sqd[18];

  if (!(fscanf(fin, "%d", &base) == 1)) {
    return 1;
  }

  for (i = 1; i <= 300; ++i) {
    squared = i * i;

    if (squared <= base) {
      convert(i, base, num);
      convert(squared, base, sqd);
      fprintf(fout, "%s %s\n", num, sqd);
    } else {
      left = squared;
      reversed = 0;

      while(left > 0) {
        rest = left % base;
        reversed = (reversed * base) + rest;
        left = left / base;
      }

      if (squared == reversed) {
        convert(i, base, num);
        convert(squared, base, sqd);
        fprintf(fout, "%s %s\n", num, sqd);
      }
    }
  }

  return 0;
}

void convert(int n, int base, char rep[]) {
  int i, j, k, power, left;

  left = n;
  i = k = 0;

  while (pow(base, ++i) <= left);
  i -= 1;

  while(i > 0) {
    j = 0;

    power = pow(base, i);

    if (power > left) {
      rep[k++] = numbers[0];
      i--;
      continue;
    }

    while ((++j * power) <= left);

    left -= (power * (j-1));
    rep[k++] = numbers[j-1];
    i--;
  }

  rep[k++] = numbers[left];
  rep[k] = '\0';
}
