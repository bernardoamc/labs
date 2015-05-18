#include <unistd.h>   // Include constants like STDIN_FILENO
#include <fcntl.h>    // Include constants like O_CREAT, for file creation
#include <sys/stat.h> // Include constants like S_IRUSR, for file permissions
#include "tlpi_hdr.h"

static const size_t BUFFER_SIZE = 1024;

void error(const char *);
int openFile(char *);
void checkOffset(int, int);
void checkOpenFlags(int, int);

int main(int argc, char *argv[]) {
  int fd, newFd;

  if (argc < 2 || strcmp(argv[1], "--help") == 0) {
    usageErr("%s filename\n", argv[0]);
  }

  fd = openFile(argv[1]);
  newFd = dup2(fd, 150);

  if (newFd == -1) {
    error("Couldn't dup file");
  }

  checkOpenFlags(fd, newFd);
  checkOffset(fd, newFd);

  if (write(fd, "Hello!", 6) != 6) {
    error("Couldn't write whole buffer to file");
  }

  checkOffset(fd, newFd);

  if (close(fd) == -1) {
    error("Failed to close file");
  }

  exit(EXIT_SUCCESS);
}

void error(const char *message) {
  printf("%s\n", message);

  exit(EXIT_FAILURE);
}

int openFile(char *name)
{
  int fileDescriptor;
  int openFileFlags = O_CREAT | O_WRONLY;
  mode_t filePermissions = S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH; /* rw-rw-rw- */

  fileDescriptor = open(name, openFileFlags, filePermissions);

  if (fileDescriptor == -1) {
    errExit("opening file");
  }

  return fileDescriptor;
}

void checkOffset(int fd1, int fd2) {
  int firstOffset, secondOffset;

  firstOffset  = lseek(fd1, 0, SEEK_CUR);
  secondOffset = lseek(fd2, 0, SEEK_CUR);

  if (firstOffset == secondOffset) {
    printf("Same offset!\n");
  } else {
    printf("Different offsets!\n");
  }
}

void checkOpenFlags(int fd1, int fd2) {
  int firstFlags, secondFlags;

  firstFlags  = fcntl(fd1, F_GETFL);
  secondFlags = fcntl(fd2, F_GETFL);

  if (firstFlags == secondFlags) {
    printf("Same flags!\n");
  } else {
    printf("Different flags!\n");
  }
}
