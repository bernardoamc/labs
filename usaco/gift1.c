/*
ID: bernard8
LANG: C
TASK: gift1
*/

#include <stdio.h>
#include <string.h>

typedef struct person {
  char name[20];
  int money;
} Person;

int find(const Person names[], const char name[], int people);

int main(void) {
  FILE *fin  = fopen ("gift1.in", "r");
  FILE *fout = fopen ("gift1.out", "w");
  Person names[10];
  char name[20];
  int i, j, k, people, total, remaining, lend, division;

  fscanf(fin, "%d ", &people);

  for(i = 0; i < people; ++i) {
    fscanf(fin, "%s ", names[i].name);
    names[i].money = 0;
  }

  for(i = 0; i < people; ++i) {
    fscanf(fin, "%s ", name);
    fscanf(fin, "%d %d", &total, &division);

    if (division == 0) {
      continue;
    }

    if (total == 0) {
      for (j = 0; j < division; j++) {
        fscanf(fin, "%s ", name);
      }

      continue;
    }

    lend = total / division;
    remaining = total - (lend * division);
    total -= remaining;

    j = find(names, name, people);
    names[j].money -= total;

    for (j = 0; j < division; j++) {
      fscanf(fin, "%s ", name);
      k = find(names, name, people);
      names[k].money += lend;
    }
  }

  for(i = 0; i < people; ++i) {
    fprintf(fout, "%s %d\n", names[i].name, names[i].money);
  }

  return 0;
}

int find(const Person names[], const char name[], int people) {
  int i;

  for(i = 0; i < people; ++i) {
    if (strcmp(names[i].name, name) == 0) return i;
  }

  return -1;
}
