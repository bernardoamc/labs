/*  access.c
 *
 *  A program that checks the permission of accessibility of the file
 *  specified in pathname based on a process’s effective user and group IDs
 *
 *  Usage: ./access file
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <errno.h>

void helpAndLeave(const char *progname, int status);
void pexit(const char *fCall);
int effective_access(const char *, int);

int main(int argc, char *argv[]) {
  if (argc != 2) {
    helpAndLeave(argv[0], EXIT_FAILURE);
  }

  if (effective_access(argv[1], W_OK) == 0) {
    printf("You have permission to write!\n");
  } else {
    printf("No permission to write!\n");
  }

  return EXIT_SUCCESS;
}

int effective_access(const char *pathname, int mode) {
  struct stat sb;
  uid_t process_user_id = geteuid();
  gid_t process_group_id = getegid();

  // If the file does not exist the errno will tell us about it
  if (stat(pathname, &sb) == -1) {
    pexit("stat");
  }

  if (process_user_id == sb.st_uid) {
    // Owner permissions
    if ((mode == R_OK && sb.st_mode & S_IRUSR) ||
        (mode == W_OK && sb.st_mode & S_IWUSR) ||
        (mode == X_OK && sb.st_mode & S_IXUSR)) {
      return 0;
    }
  } else if(process_group_id == sb.st_gid) {
    // Group permissions
    if ((mode == R_OK && sb.st_mode & S_IRGRP) ||
        (mode == W_OK && sb.st_mode & S_IWGRP) ||
        (mode == X_OK && sb.st_mode & S_IXGRP)) {
      return 0;
    }
  } else {
    // Other permissions
    if ((mode == R_OK && sb.st_mode & S_IROTH) ||
        (mode == W_OK && sb.st_mode & S_IWOTH) ||
        (mode == X_OK && sb.st_mode & S_IXGRP)) {
      return 0;
    }
  }

  return -1;
}

void helpAndLeave(const char *progname, int status) {
  FILE *stream = stderr;

  if (status == EXIT_SUCCESS) {
    stream = stdout;
  }

  fprintf(stream, "Usage: %s <filename>\n", progname);
  exit(status);
}

void pexit(const char *fCall) {
  perror(fCall);
  exit(EXIT_FAILURE);
}
