/*
ID: bernard8
LANG: C
TASK: milk
*/

#include <stdio.h>

typedef struct farm {
  int liters;
  int price;
} Farm;

Farm farms[5000];
Farm aux[5000];

void mergeSort (int, int);
void concat (int, int, int);

int main(void) {
  FILE *fin  = fopen ("milk.in", "r");
  FILE *fout = fopen ("milk.out", "w");

  int liters, farmers, i, litersRemaining, totalCost = 0;

  if (!(fscanf(fin, "%d %d", &liters, &farmers) == 2)) {
    return 1;
  }

  for(i = 0; i < farmers; ++i) {
    if (!(fscanf(fin, "%d %d", &farms[i].price, &farms[i].liters) == 2)) {
      return 1;
    }
  }

  mergeSort(0, farmers - 1);

  litersRemaining = liters;

  for(i = 0; i < farmers; ++i) {
    if ((litersRemaining - farms[i].liters) >= 0) {
      litersRemaining -= farms[i].liters;
      totalCost += (farms[i].liters * farms[i].price);
    } else {
      totalCost += (farms[i].price * litersRemaining);
      break;
    }
  }

  fprintf(fout, "%d\n", totalCost);

  return 0;
}

void mergeSort (int begin, int end)
{
  int middle;

  if(begin < end) {
    middle = (begin + end) / 2;

    mergeSort(begin, middle);
    mergeSort(middle + 1, end);
    concat(begin, middle, end);
  }
}

void concat (int begin, int middle, int end)
{
  int leftPos = begin, leftEnd = middle, rightPos = middle + 1, itemsSorted = 0, i;

  while(leftPos <= leftEnd && rightPos <= end) {
    if (farms[leftPos].price < farms[rightPos].price) {
      aux[itemsSorted++] = farms[leftPos++];
    } else {
      aux[itemsSorted++] = farms[rightPos++];
    }
  }

  while(leftPos <= leftEnd) {
    aux[itemsSorted++] = farms[leftPos++];
  }

  while(rightPos <= end) {
    aux[itemsSorted++] = farms[rightPos++];
  }

  for(i = 0; i < itemsSorted; i++) {
    farms[i + begin] = aux[i];
  }
}
