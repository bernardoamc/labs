#include <unistd.h>   // Include constants like STDIN_FILENO
#include <fcntl.h>    // Include constants like O_CREAT, for file creation
#include <sys/stat.h> // Include constants like S_IRUSR, for file permissions
#include "tlpi_hdr.h"

#ifndef BOOL_TYPES
typedef int bool;
#define false 0
#define true 1
#endif

void error(const char *message);
int dupClone(int fd);
int dup2Clone(int fd, int newFd);

int main(int argc, char *argv[]) {
  exit(EXIT_SUCCESS);
}

void error(const char *message) {
  printf("%s\n", message);

  exit(EXIT_FAILURE);
}

int dupClone(int fd) {
  return fcntl(fd, F_DUPFD);
}

int dup2Clone(int fd, int newFd) {
  // If fd == newFd we should check if fd is valid
  // and just return the newFd if it is, otherwise we
  // return -1, meaning that the fd is not valid
  if (fd == newFd) {
    if (fcntl(fd, F_GETFL) != -1) {
      return newFd;
    } else {
      return -1;
    }
  }

  if (close(newFd) == -1) {
    error("Failed to close the new file descriptor");
  }

  return fcntl(fd, F_DUPFD, newFd);
}
