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
  int inputFileDescriptor, outputFileDescriptor;
  ssize_t bytesRead;
  char buffer[BUF_SIZE];

  if (argc != 3 || strcmp(argv[1], "--help") == 0) {
    usageErr("%s inputFile outputFile\n", argv[0]);
  }

  inputFileDescriptor = openFile(argv[1], false);
  outputFileDescriptor = openFile(argv[2], true);

  while ((bytesRead = read(inputFileDescriptor, buffer, BUF_SIZE)) > 0) {
    if (write(outputFileDescriptor, buffer, bytesRead) != bytesRead) {
      error("Couldn't write whole buffer to file");
    }
  }

  if (bytesRead == -1) {
    error("Couldn't read from file");
  }

  if (close(inputFileDescriptor) == -1) {
    error("Failed to close input file");
  }

  if (close(outputFileDescriptor) == -1) {
    error("Failed to close output file");
  }

  exit(EXIT_SUCCESS);
}

void error(const char *message) {
  printf("%s\n", message);

  exit(EXIT_FAILURE);
}

int openFile(char *name, bool write)
{
  int fileDescriptor;
  int openReadFileFlags  = O_RDONLY;
  int openWriteFileFlags = O_CREAT | O_WRONLY | O_TRUNC;
  mode_t filePermissions = S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH; /* rw-rw-rw- */

  if (write) {
    fileDescriptor = open(name, openWriteFileFlags, filePermissions);
  } else {
    fileDescriptor = open(name, openReadFileFlags);
  }

  if (fileDescriptor == -1) {
    error("opening file");
  }

  return fileDescriptor;
}
