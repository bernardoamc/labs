/*
ID: bernard8
LANG: C
TASK: namenum
*/

/*
  2: A,B,C     5: J,K,L    8: T,U,V
  3: D,E,F     6: M,N,O    9: W,X,Y
  4: G,H,I     7: P,R,S
*/

#include <stdio.h>
#include <string.h>

#define NAMES_SIZE 5000

int found = 0;
char names[NAMES_SIZE][20];
char serial[13];
char codes[8][3] = {
  {'A', 'B', 'C'}, {'D', 'E', 'F'}, {'G', 'H', 'I'}, {'J', 'K', 'L'},
  {'M', 'N', 'O'}, {'P', 'R', 'S'}, {'T', 'U', 'V'}, {'W', 'X', 'Y'}
} ;

int search(const char []);
int read_input(FILE *);
void read_names(FILE *);
void possible_names(FILE *, const char [], int, int);

int main(int argc, char *argv[]) {
  FILE *fin   = fopen ("namenum.in", "r");
  FILE *fout  = fopen ("namenum.out", "w");
  FILE *dict = fopen ("dict.txt", "r");
  int serial_size = 0;
  char name[] = {};

  serial_size = read_input(fin);
  read_names(dict);
  possible_names(fout, name, 0, serial_size);
  if(!found) fprintf(fout, "NONE\n");

  return 0;
}

int read_input(FILE *fin) {
  int letter, serial_size = 0;

  while ((letter = fgetc(fin)) != '\n') {
    serial[serial_size++] = letter;
  }

  serial[serial_size] = '\0';

  return serial_size;
}

void read_names(FILE *dict) {
  int letter, line = 0, at = 0;

  while ((letter = fgetc(dict)) != EOF) {
    if (letter == '\n') {
      names[line][at] = '\0';

      at = 0;
      line++;
    } else {
      names[line][at] = letter;
      at++;
    }
  }
}

int search(const char name[]) {
  int min = 0, middle = 2500, max = 5000, compare = 0;

  while (min <= max) {
    middle = min + ((max - min) / 2);
    compare = strncmp(names[middle], name, 15);

    if (compare < 0) {
      min = middle + 1;
    } else if (compare > 0) {
      max = middle - 1;
    } else {
      return middle;
    }
  }

  return -1;
}

void possible_names(FILE *fout, const char partial_name[], int word_size, int serial_size) {
  char name[13];
  int translation, i;

  strncpy(name, partial_name, word_size);

  if (word_size == serial_size) {
    name[serial_size] = '\0';
    int answer = search(name);

    if (answer != -1) {
      fprintf(fout, "%s\n", names[answer]);
      found = 1;
    }

    return;
  }

  translation = serial[word_size] - '2';

  for (i = 0; i < 3; i++) {
    name[word_size] = codes[translation][i];
    possible_names(fout, name, word_size + 1, serial_size);
  }
}
