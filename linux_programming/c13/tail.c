#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>

#define BUFF 1024

void usage(void);
void error(const char *);
int tail(FILE *, long int *, int, int, long int);
int countLines(FILE *, long int *, int, int, int, int);

int main(int argc, char *argv[])
{
  FILE *file = NULL;
  int opt, lines = 10;
  int c;
  char *end = NULL;
  long int *linePos;
  long int offset;

  while ((opt = getopt(argc, argv, "n:")) != -1) {
    if (opt == 'n') {
      lines = strtol(optarg, &end, 10);
    }
  }

  if (end != NULL && *end != '\0') usage();
  if (optind == argc) usage();

  linePos = malloc(sizeof(int));

  if (linePos == NULL) {
    error("Failure allocating line position");
  }

  if ((file = fopen(argv[optind], "r")) == NULL) {
    error("Failure opening file");
  }

  fseek(file, 0, SEEK_END);
  offset = tail(file, linePos, 0, lines, ftell(file));
  fseek(file, offset, SEEK_SET);

  while ((c = fgetc(file)) != EOF) {
    printf("%c", c);
  }

  free(linePos);

  if (fclose(file) == EOF) {
    error("Failure closing file");
  }

  exit(EXIT_SUCCESS);
}

void usage(void) {
  printf("Invalid arguments\nUsage: tail -n num file\n");
  exit(EXIT_FAILURE);
}

void error(const char *message) {
  printf("%s\n", message);
  exit(EXIT_FAILURE);
}

int countLines(FILE *file, long int *linePos, int lines, int totalLines, int size, int position) {
  int i = 0, buffer[size];

  while(i < size) {
    buffer[i++] = fgetc(file);
  }

  i--;

  while (i--) {
    if (buffer[i] == '\n') {
      lines++;

      if (lines == totalLines) {
        *linePos = position + i;
        break;
      }
    }
  }

  return lines;
}

int tail(FILE *file, long int *linePos, int lines, int totalLines, long int offsetStart) {
  if ((offsetStart - BUFF) <= 0) {
    fseek(file, 0, SEEK_SET);
    lines = countLines(file, linePos, lines, totalLines, offsetStart, 0);
  } else {
    offsetStart -= BUFF;
    fseek(file, offsetStart, SEEK_SET);
    lines = countLines(file, linePos, lines, totalLines, BUFF, offsetStart);
  }

  if (lines >= totalLines) {
    return *linePos + 1; // One after the \n
  } else if ((offsetStart - BUFF) <= 0) {
    return 0;
  } else {
    return tail(file, linePos, lines, totalLines, offsetStart - BUFF);
  }
}
