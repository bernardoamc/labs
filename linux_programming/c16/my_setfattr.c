/*  my_setfattr.c
 *
 *  This program sets and updates user EAs
 *
 *  Usage: ./my_setfattr file ea value
 */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/xattr.h>
#include <string.h>

#define MAX_NAME 255

void helpAndLeave(const char *progname, int status);
void pexit(const char *fCall);

int main(int argc, char *argv[]) {
  char ea[MAX_NAME];

  if (argc != 4) {
    helpAndLeave(argv[0], EXIT_FAILURE);
  }

  snprintf(ea, MAX_NAME, "user.%s", argv[2]);

  if (setxattr(argv[1], ea, argv[3], strlen(argv[3]), 0, 0) == -1) {
    pexit("setxattr");
  }

  return EXIT_SUCCESS;
}

void helpAndLeave(const char *progname, int status) {
  FILE *stream = stderr;

  if (status == EXIT_SUCCESS) {
    stream = stdout;
  }

  fprintf(stream, "Usage: %s file ea value", progname);
  exit(status);
}

void pexit(const char *fCall) {
  perror(fCall);
  exit(EXIT_FAILURE);
}
