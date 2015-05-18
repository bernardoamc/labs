#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>    // Include constants like O_CREAT, for file creation
#include <sys/stat.h> // Include constants like S_IRUSR, for file permissions

void error(const char *);
int openFile(char *);

int main(int argc, char *argv[]) {
  int fileDescriptor;
  const char *endMessage = "Hole created!";

  fileDescriptor = openFile(argv[1]);

  lseek(fileDescriptor, 10 * 4096, SEEK_END);

  if (write(fileDescriptor, endMessage, 13) != 13) {
    error("Couldn't write whole buffer to file");
  }

  if (close(fileDescriptor) == -1) {
    error("Failed to close output file");
  }

  exit(0);
}

void error(const char *message) {
  printf("%s\n", message);

  exit(1);
}

int openFile(char *name)
{
  int fileDescriptor;
  int openFileFlags  = O_WRONLY | O_APPEND;

  fileDescriptor = open(name, openFileFlags);

  if (fileDescriptor == -1) {
    error("opening file");
  }

  return fileDescriptor;
}
