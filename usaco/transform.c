/*
ID: bernard8
LANG: C
TASK: transform
*/
#include <stdio.h>

int check(int);
int rotation90(int);
int rotation180(int);
int rotation270(int);
int reflection(int);
int reflection90(int);
int reflection180(int);
int reflection270(int);
int noChange(int);

char original[10][10] = {{0}};
char transformed[10][10] = {{0}};

int main(int argc, char *argv[]) {
  FILE *fin  = fopen ("transform.in", "r");
  FILE *fout = fopen ("transform.out", "w");
  int size, i, j;

  fscanf (fin, "%d ", &size);

  for(i = 0; i < size; ++i) {
    for(j = 0; j < size; ++j) {
      fscanf (fin, "%c ", &original[i][j]);
    }
  }

  for(i = 0; i < size; ++i) {
    for(j = 0; j < size; ++j) {
      fscanf (fin, "%c ", &transformed[i][j]);
    }
  }

  fprintf (fout, "%d\n", check(size));

  return 0;
}

int check(int size) {
  if (rotation90(size))  return 1;
  if (rotation180(size)) return 2;
  if (rotation270(size)) return 3;
  if (reflection(size))  return 4;
  if (reflection90(size))  return 5;
  if (reflection180(size)) return 5;
  if (reflection270(size)) return 5;
  if (noChange(size)) return 6;

  return 7;
}

/*
  // Ini
  0 1 2
  3 4 5
  6 7 8

  // 90
  6 3 0
  7 4 1
  8 5 2
*/
int rotation90(int size) {
  int i, j, same = 0;

  for (i = 0; i < size; ++i) {
    for (j = 0; j < size; ++j) {
      if (original[i][j] == transformed[j][size - i - 1]) {
        same++;
      }
    }
  }

  return (same == (size * size));
}

/*
  // Ini    // Ref
  0 1 2     2 1 0
  3 4 5     5 4 3
  6 7 8     8 7 6
*/
int reflection(int size) {
  int i, j, same = 0;

  for (i = 0; i < size; ++i) {
    for (j = 0; j < size; ++j) {
      if (original[j][i] == transformed[j][size - i - 1])
       same++;
    }
  }

  return (same == (size * size));
}

/*
  // Ini    // Ref
  0 1 2     2 1 0
  3 4 5     5 4 3
  6 7 8     8 7 6

  // 90 Ref
  8 5 2
  7 4 1
  6 3 0
*/

int reflection90(int size) {
  int i, j, same = 0;

  for (i = 0; i < size; ++i) {
    for (j = 0; j < size; ++j) {
      if (original[j][i] == transformed[size - i - 1][size - j - 1]) {
        same++;
      }
    }
  }

  return (same == (size * size));
}

/*
  // Ini    // Ref
  0 1 2     2 1 0
  3 4 5     5 4 3
  6 7 8     8 7 6

  // 180    // 180 Ref
  8 7 6     6 7 8
  5 4 3     3 4 5
  2 1 0     0 1 2
*/
int rotation180(int size) {
  int i, j, same = 0;

  for (i = 0; i < size; ++i) {
    for (j = 0; j < size; ++j) {
      if (original[i][j] == transformed[size - i - 1][size - j - 1]) {
        same++;
      }
    }
  }

  return (same == (size * size));
}

/*
  // Ini    // Ref
  0 1 2     2 1 0
  3 4 5     5 4 3
  6 7 8     8 7 6

  // 180 Ref
  6 7 8
  3 4 5
  0 1 2
*/
int reflection180(int size) {
  int i, j, same = 0;

  for (i = 0; i < size; ++i) {
    for (j = 0; j < size; ++j) {
      if (original[i][j] == transformed[size - i - 1][j]) {
        same++;
      }
    }
  }

  return (same == (size * size));
}

/*
  // Ini    // Ref
  0 1 2     2 1 0
  3 4 5     5 4 3
  6 7 8     8 7 6

  // 270    // 270 Ref
  2 5 8     0 3 6
  1 4 7     1 4 7
  0 3 6     2 5 8
*/
int rotation270(int size) {
  int i, j, same = 0;

  for (i = 0; i < size; ++i) {
    for (j = 0; j < size; ++j) {
      if (original[i][j] == transformed[size - j - 1][i]) {
        same++;
      }
    }
  }

  return (same == (size * size));
}

/*
  // Ini    // Ref
  0 1 2     2 1 0
  3 4 5     5 4 3
  6 7 8     8 7 6

  // 270 Ref
  0 3 6
  1 4 7
  2 5 8
*/
int reflection270(int size) {
  int i, j, same = 0;

  for (i = 0; i < size; ++i) {
    for (j = 0; j < size; ++j) {
      if (original[j][i] == transformed[i][j]) {
        same++;
      }
    }
  }

  return (same == (size * size));
}

int noChange(int size) {
  int i, j, same = 0;

  for (i = 0; i < size; ++i) {
    for (j = 0; j < size; ++j) {
      if (original[i][j] == transformed[i][j]) {
        same++;
      }
    }
  }

  return (same == (size * size));
}
