/*
 * This happens because a file opened with the O_APPEND flag
 * will always write to the end of the file.
 *
 * It's as if we are doind lseek(fg, 0, SEEK_END) + write.
 * The difference is that this happen atomically.
 *
 */

#include <unistd.h>   // Include constants like STDIN_FILENO
#include <fcntl.h>    // Include constants like O_CREAT, for file creation
#include <sys/stat.h> // Include constants like S_IRUSR, for file permissions
#include "tlpi_hdr.h"

#ifndef BOOL_TYPES
typedef int bool;
#define false 0
#define true 1
#endif

static const size_t BUFFER_SIZE = 1024;

void error(const char *);
int openFile(char *, bool);

int main(int argc, char *argv[]) {
  int fileDescriptor, bytesToWrite = 6;
  ssize_t bytesWritten;
  char *buffer = "Hello!";

  if (argc < 2 || strcmp(argv[1], "--help") == 0) {
    usageErr("%s filename\n", argv[0]);
  }

  fileDescriptor = openFile(argv[1], true);

  if (write(fileDescriptor, buffer, bytesToWrite) != bytesToWrite) {
    error("Couldn't write whole buffer to file");
  }

  if (write(fileDescriptor, buffer, bytesToWrite) != bytesToWrite) {
    error("Couldn't write whole buffer to file");
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
