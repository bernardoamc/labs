/*  chmod_arx.c
 *
 * Enables read permission for all categories of user, and likewise enables
 * execute permission for all categories of user if file is a directory or
 * execute permission is enabled for any of the user categories for file.
 *
 *  Usage: ./chmod_arx file1 file2 ...
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <errno.h>

void helpAndLeave(const char *progname, int status);
void pexit(const char *fCall);
int chmod_arx(const char *pathname);

int main(int argc, char *argv[]) {
  int i;

  if (argc < 2) {
    helpAndLeave(argv[0], EXIT_FAILURE);
  }

  for (i = 1; i < argc; ++i) {
    if (chmod_arx(argv[i]) == 0) {
      printf("Permissions modified!\n");
    } else {
      pexit("chmod");
    }
  }

  return EXIT_SUCCESS;
}

int chmod_arx(const char *pathname) {
  struct stat sb;
  mode_t r = S_IRUSR | S_IRGRP | S_IROTH;
  mode_t r_x = r | S_IXUSR | S_IXGRP | S_IXOTH;
  mode_t permissions;

  // If the file does not exist the errno will tell us about it
  if (stat(pathname, &sb) == -1) {
    pexit("stat");
  }

  if (((sb.st_mode & S_IFMT) == S_IFDIR) ||
       ((sb.st_mode & S_IXUSR) || (sb.st_mode & S_IXGRP) || (sb.st_mode & S_IXOTH))) {
    permissions = r_x | sb.st_mode;
  } else {
    permissions = r | sb.st_mode;
  }

  return chmod(pathname, permissions);
}

void helpAndLeave(const char *progname, int status) {
  FILE *stream = stderr;

  if (status == EXIT_SUCCESS) {
    stream = stdout;
  }

  fprintf(stream, "Usage: %s file <file> ...\n", progname);
  exit(status);
}

void pexit(const char *fCall) {
  perror(fCall);
  exit(EXIT_FAILURE);
}
