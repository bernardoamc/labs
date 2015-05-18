#include <unistd.h>   // Include constants like STDIN_FILENO
#include <fcntl.h>    // Include constants like O_CREAT, for file creation
#include <sys/stat.h> // Include constants like S_IRUSR, for file permissions
#include <sys/uio.h>
#include "tlpi_hdr.h"

static const size_t BUFFER_SIZE = 25;

typedef struct my_iovec {
  void *base; /* Start address of buffer */
  size_t len; /* Number of bytes to transfer to/from buffer */
} Iovec;

void error(const char *);
int openFile(char *);
ssize_t readv_dup(int fd, const Iovec *iov, int iovcount);
ssize_t writev_dup(int fd, const Iovec *iov, int iovcount);

int main(int argc, char *argv[]) {
  Iovec iov[2];
  int fd;
  ssize_t bytesRead, bytesWritten, totalBytesRead, totalBytesWritten;
  char buffer1[BUFFER_SIZE], buffer2[BUFFER_SIZE];

  if (argc < 2 || strcmp(argv[1], "--help") == 0) {
    usageErr("%s filename\n", argv[0]);
  }

  fd = openFile(argv[1]);

  iov[0].base = buffer1;
  iov[0].len  = BUFFER_SIZE;

  iov[1].base = buffer2;
  iov[1].len  = BUFFER_SIZE;

  totalBytesRead = totalBytesWritten = 2 * BUFFER_SIZE;

  bytesRead = readv_dup(fd, iov, 2);

  printf("Total bytes requested: %ld; bytes read: %ld\n", (long) totalBytesRead, (long) bytesRead);

  if (lseek(fd, 0, SEEK_END) == -1) {
    error("seeking to the end of the file");
  }

  bytesWritten = writev_dup(fd, iov, 2);

  printf("Total bytes requested: %ld; bytes written: %ld\n", (long) totalBytesWritten, (long) bytesWritten);

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
  int fd;

  fd = open(name, O_RDWR);

  if (fd == -1) {
    errExit("opening file");
  }

  return fd;
}

ssize_t readv_dup(int fd, const Iovec *iov, int iovcount) {
  int i;
  size_t memSize = 0;
  ssize_t numCopied, numRead;
  void *buf;

  /* Calculates all the space that will be required */
  for (i = 0; i < iovcount; ++i) {
    memSize += iov[i].len;
  }

  buf = malloc(memSize);
  if (buf == NULL) {
    error("malloc");
  }

  /* Reads all the data from the file into the buffer */
  numRead = read(fd, buf, memSize);
  if (numRead == -1) {
    return numRead;
  }

  /* Copies read data to the iovec structure */
  numCopied = 0;
  for (i = 0; i < iovcount; ++i) {
    memcpy(iov[i].base, buf + numCopied, iov[i].len);
    numCopied += iov[i].len;
  }

  free(buf);

  return numRead;
}

ssize_t writev_dup(int fd, const Iovec *iov, int iovcount) {
  int i;
  size_t memSize;
  ssize_t numCopied, numWritten;
  void *buf;

  /* Calculates all the space that will be required */
  memSize = 0;
  for (i = 0; i < iovcount; ++i) {
    memSize += iov[i].len;
  }

  buf = malloc(memSize);
  if (buf == NULL) {
    error("malloc");
  }

  /* Copies data to the buffer */
  numCopied = 0;
  for (i = 0; i < iovcount; ++i) {
    memcpy(buf + numCopied, iov[i].base, iov[i].len);
    numCopied += iov[i].len;
  }

  numWritten = write(fd, buf, memSize);
  free(buf);

  return numWritten;
}
