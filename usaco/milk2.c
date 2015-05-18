/*
ID: bernard8
LANG: C
TASK: milk2
*/

#include <stdio.h>

typedef struct interval {
  int start;
  int end;
} Interval;

void mergeSort (Interval [], Interval [], int, int);
void concat (Interval [], Interval [], int, int, int);

Interval intervals[5001];
Interval aux[5001];

int main(void) {
  FILE *fin  = fopen ("milk2.in", "r");
  FILE *fout = fopen ("milk2.out", "w");
  int i, j, farmers;
  int start, end, longest, idle;

  fscanf (fin, "%d ", &farmers);

  for(i = 0; i < farmers; ++i) {
    fscanf (fin, "%d %d ", &intervals[i].start, &intervals[i].end);
  }

  mergeSort(intervals, aux, 0, farmers - 1);

  start = intervals[0].start;
  end = intervals[0].end;
  longest = idle = j = 0;

  for(i = 0; i < farmers; ++i) {
    if (intervals[i].start >= start && intervals[i].start <= end && intervals[i].end >= end) {
      end = intervals[i].end;
    } else if (intervals[i].start > end) {
      j++;
      start = intervals[i].start;
      end = intervals[i].end;
    }

    aux[j].start = start;
    aux[j].end = end;
  }

  aux[j+1] = aux[j];

  for (i = 0; i <= j; i++) {
    if (aux[i].end - aux[i].start > longest) longest = aux[i].end - aux[i].start;
    if (aux[i+1].start - aux[i].end > idle) idle = aux[i+1].start - aux[i].end;
  }

  fprintf (fout, "%d %d\n", longest, idle);

  return 0;
}

void mergeSort (Interval intervals[], Interval aux[], int begin, int end) {
  int middle;

  if(begin < end) {
    middle = (begin + end) / 2;

    mergeSort(intervals, aux, begin, middle);
    mergeSort(intervals, aux, middle + 1, end);
    concat(intervals, aux, begin, middle, end);
  }
}

void concat (Interval intervals[], Interval aux[], int begin, int middle, int end) {
  int leftPos = begin, leftEnd = middle, rightPos = middle + 1, itemsSorted = 0, i;

  while(leftPos <= leftEnd && rightPos <= end) {
    if (intervals[leftPos].start < intervals[rightPos].start) {
      aux[itemsSorted++] = intervals[leftPos++];
    } else {
      aux[itemsSorted++] = intervals[rightPos++];
    }
  }

  while(leftPos <= leftEnd) {
    aux[itemsSorted++] = intervals[leftPos++];
  }

  while(rightPos <= end) {
    aux[itemsSorted++] = intervals[rightPos++];
  }

  for(i = 0; i < itemsSorted; i++) {
    intervals[i + begin] = aux[i];
  }
}
