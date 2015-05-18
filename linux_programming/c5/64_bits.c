#define _FILE_OFFSET_BITS 64

#include <unistd.h>   // Include constants like STDIN_FILENO
#include <fcntl.h>    // Include constants like O_CREAT, for file creation
#include <sys/stat.h> // Include constants like S_IRUSR, for file permissions
#include "tlpi_hdr.h"

#ifndef BOOL_TYPES
typedef int bool;
#define false 0
#define true 1
#endif

void error(const char *);
int openFile(char *, bool);

int main(int argc, char *argv[]) {
  bool appendMode = false;
  int fileDescriptor, totalBytesToWrite;
  ssize_t bytesToWrite = 1;
  off_t offset = 0;
  char *buffer = "x";

  if (argc < 3 || strcmp(argv[1], "--help") == 0) {
    usageErr("%s filename num-bytes [x]\n", argv[0]);
  }

  if (argc == 4) {
    if (argv[3][0] == 'x') {
      appendMode = true;
    } else {
      printf("%c\n", argv[3][0]);
      usageErr("%s filename num-bytes [x]", argv[0]);
    }
  }

  totalBytesToWrite = atoi(argv[2]);

  if (totalBytesToWrite == 0) {
    usageErr("%s filename num-bytes [x]", argv[0]);
  }

  fileDescriptor = openFile(argv[1], appendMode);

  while (--totalBytesToWrite > 0) {
    if(appendMode) {
      if ((lseek(fileDescriptor, offset, SEEK_END)) == -1) {
        error("Couldn't lseek to the end of the file");
      }
    }

    if (write(fileDescriptor, buffer, bytesToWrite) != 1) {
      error("Couldn't write whole buffer to file");
    }
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
  }

  fileDescriptor = open(name, openFileFlags, filePermissions);

  if (fileDescriptor == -1) {
    errExit("opening file");
  }

  return fileDescriptor;
}
