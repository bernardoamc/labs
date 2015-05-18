/*
 * Usage: ./tempfiles targetDir number_of_files
 *
 * The type of the File System will influence a lot in the running
 * time of this program.
 *
 * Since the files will be really small the file data blocks can be accessed rapidly
 * via the direct pointers of the i-node.
 *
 * - Virtual Memory File System will be the fastest ones since no disk access is involved.
 *
 * - File Systems that don't have journaling tends to be faster since it will
 * not log any metadata before a file update.
 *
 * - File Systems that have journaling will take a little longer due to the
 *   explanation above. If they log filedata (ext3, ext4 and Reiserfs can do that)
 *   it will be even slower.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <time.h>
#include <fcntl.h>
#include <unistd.h>

#define PATH_MAX 1024

void helpAndLeave(const char *progname, int status);
void pexit(const char *fCall);
int compareNames (const void *a, const void *b);

int main(int argc, char *argv[]) {
  int files, i, fd;
  char filename[PATH_MAX];
  int *filenames;

  if (argc != 3) {
    helpAndLeave(argv[0], EXIT_FAILURE);
  }

  errno = 0;
  files = strtol(argv[2], NULL, 10);

  if(errno) {
    pexit("strtol");
  }

  if (!files) {
    helpAndLeave(argv[0], EXIT_FAILURE);
  }

  filenames = malloc(files * sizeof(int));

  if (filenames == NULL) {
    pexit("malloc");
  }

  for (i = 0; i < files; i++) {
    filenames[i] = rand() % 1000000;
    snprintf(filename, PATH_MAX, "%s/x%06d", argv[1], filenames[i]);
    errno = 0;

    while(((fd = open(filename, O_WRONLY | O_CREAT | O_EXCL)) == -1) && (!errno || errno == EEXIST)) {
      filenames[i] = rand() % 1000000;
      snprintf(filename, PATH_MAX, "%s/x%06d", argv[1], filenames[i]);
    }

    if (errno && errno != EEXIST) {
      pexit("open");
    }

    if (write(fd, "a", 1) != 1) {
      pexit("write");
    }

    if (close(fd) == -1) {
      pexit("close");
    }
  }

  qsort(filenames, files, sizeof(int), compareNames);

  for (i = 0; i < files; i++) {
    snprintf(filename, PATH_MAX, "%s/x%06d", argv[1], filenames[i]);

    if (unlink(filename) == -1) {
      pexit("unlink");
    }
  }

  free(filenames);

  exit(EXIT_SUCCESS);
}

void helpAndLeave(const char *progname, int status) {
  FILE *stream = stderr;

  if (status == EXIT_SUCCESS) {
    stream = stdout;
  }

  fprintf(stream, "Usage: %s  <dir> <number_of_files_greater_than_zero>\n", progname);
  exit(status);
}

void pexit(const char *fCall) {
  perror(fCall);
  exit(EXIT_FAILURE);
}

int compareNames (const void *a, const void *b)
{
   return ( *(int*)a - *(int*)b );
}
