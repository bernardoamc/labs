/*  chattr.c
 *
 *  This program is a copy of chattr without the -R, -V and -v flags
 *
 *  Usage: ./chattr flags file
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <linux/fs.h>

void helpAndLeave(const char *progname, int status);
void pexit(const char *fCall);

int main(int argc, char *argv[]) {
  int flags, fd, i;
  char type;

  if (argc < 3) {
    helpAndLeave(argv[0], EXIT_FAILURE);
  }

  if ((fd = open(argv[2], O_RDONLY)) == -1) {
    pexit("open");
  }

  for (i = 1; i < strlen(argv[1]); i++) {
    switch (argv[1][i]) {
      case 'a': flags |= FS_APPEND_FL;         break;
      case 'A': flags |= FS_NOATIME_FL;        break;
      case 'c': flags |= FS_COMPR_FL;          break;
      case 'd': flags |= FS_NODUMP_FL;         break;
      case 'D': flags |= FS_DIRSYNC_FL;        break;
      case 'i': flags |= FS_IMMUTABLE_FL;      break;
      case 'j': flags |= FS_JOURNAL_DATA_FL;   break;
      case 's': flags |= FS_SECRM_FL;          break;
      case 'S': flags |= FS_SYNC_FL;           break;
      case 't': flags |= FS_NOTAIL_FL;         break;
      case 'T': flags |= FS_TOPDIR_FL;         break;
      case 'u': flags |= FS_UNRM_FL;           break;
      default:
        printf("Unsuported flag!");
        return EXIT_FAILURE;
    }
  }

  type = argv[1][0]; // '+' or '-'

  if (chattr(fd, flags, type) == -1) {
    pexit("ioctl");
  }

  if (close(fd) == -1) {
    pexit("close");
  }

  return EXIT_SUCCESS;
}

int chattr(int fd, int flags, char type) {
  int oldFlags;

  if (ioctl(fd, FS_IOC_GETFLAGS, &oldFlags) == -1) {
    return -1;
  }

  if (type == '+') {
    flags = oldFlags | flags;
  } else {
    flags = oldFlags & ~flags;
  }

  return ioctl(fd, FS_IOC_SETFLAGS, &flags) == -1;
}

void helpAndLeave(const char *progname, int status) {
  FILE *stream = stderr;

  if (status == EXIT_SUCCESS) {
    stream = stdout;
  }

  fprintf(stream, "Usage: %s flags file", progname);
  exit(status);
}

void pexit(const char *fCall) {
  perror(fCall);
  exit(EXIT_FAILURE);
}
