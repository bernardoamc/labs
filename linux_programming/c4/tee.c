#include <unistd.h>   // Include constants like STDIN_FILENO
#include <fcntl.h>    // Include constants like O_CREAT, for file creation
#include <sys/stat.h> // Include constants like S_IRUSR, for file permissions
#include "tlpi_hdr.h"

#ifndef BUF_SIZE
#define BUF_SIZE 1024
#endif

#ifndef BOOL_TYPES
typedef int bool;
#define false 0
#define true 1
#endif

void error(const char *);
int openFile(char *, bool);

int main(int argc, char *argv[]) {
  bool appendMode = false;
  int opt, fileDescriptor;
  ssize_t bytesRead;
  char buffer[BUF_SIZE];

  if (argc < 2 || argc > 3 || strcmp(argv[1], "--help") == 0) {
    usageErr("%s [-a] filename\n", argv[0]);
  }

  opt = getopt(argc, argv, "a");

  if (opt != -1) {
    if (opt == 'a') {
      appendMode = true;
    } else {
      usageErr("%s [-a] filename", argv[0]);
    }
  }

  fileDescriptor = openFile(argv[optind], appendMode);

  while ((bytesRead = read(STDIN_FILENO, buffer, BUF_SIZE)) > 0) {
    if (write(fileDescriptor, buffer, BUF_SIZE) != bytesRead) {
      error("Couldn't write whole buffer to file");
    }

    if (write(STDOUT_FILENO, buffer, BUF_SIZE) != bytesRead) {
      error("Couldn't write whole buffer to stdout");
    }
  }

  if (bytesRead == -1) {
    error("Couldn't read from file");
  }

  if (close(fileDescriptor) == -1) {
    error("Failed to close file");
  }

  exit(EXIT_SUCCESS);
}

void error(const char *message) {
  printf("%s\n", message);

  exit(EXIT_FAILURE);
}

int openFile(char *name, bool appendMode)
{
  int fileDescriptor;
  int openFileFlags = O_CREAT | O_WRONLY;
  mode_t filePermissions = S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH; /* rw-rw-rw- */

  if (appendMode) {
    openFileFlags |= O_APPEND;
  } else {
    openFileFlags |= O_TRUNC;
  }

  fileDescriptor = open(name, openFileFlags, filePermissions);

  if (fileDescriptor == -1) {
    errExit("opening file");
  }

  return fileDescriptor;
}
