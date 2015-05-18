#include <limits.h>
#include <ctype.h>
#include <dirent.h>
#include <pwd.h>
#include "tlpi_hdr.h"

#define BUFFER 1000

uid_t userIdFromName(const char *);
void checkProcessStatus(char *, uid_t);

int main(int argc, char *argv[])
{
  uid_t uid;
  DIR *dir;
  struct dirent *dirEntry;

  if (argc < 2 || strcmp(argv[1], "--help") == 0) {
    usageErr("%s username\n", argv[0]);
  }

  uid = userIdFromName(argv[1]);

  if (uid == -1) {
    printf("Invalid username!\n");
    exit(EXIT_FAILURE);
  }

  dir = opendir("/proc");

  if (dir == NULL) {
    errExit("opendir");
  }

  while(1) {
    // Applications wishing to check for error situations should set errno to 0 before calling readdir().
    // If errno is set to non-zero on return, an error occurred.
    errno = 0;
    dirEntry = readdir(dir);

    if (dirEntry == NULL) {
      if (errno != 0) {
        errExit("readdir");
      }

      break;
    }

    if (dirEntry->d_type != DT_DIR || !isdigit((unsigned char) dirEntry->d_name[0])) {
      continue;
    }

    checkProcessStatus(dirEntry->d_name, uid);
  }

  exit(EXIT_SUCCESS);
}

uid_t userIdFromName(const char *name)
{
  struct passwd *pwd;

  if (name == NULL || *name == '\0') {
    return -1;
  }

  pwd = getpwnam(name);

  if (pwd == NULL) {
      return -1;
  }

  return pwd->pw_uid;
}

void checkProcessStatus(char *pid, uid_t uid) {
  char path[PATH_MAX], line[BUFFER], command[BUFFER];
  FILE *status;
  char *position;
  uid_t processUid;
  int uidSeen = 0, commandSeen = 0;

  snprintf(path, PATH_MAX, "/proc/%s/status", pid);

  status = fopen(path, "r");

  if (status == NULL) {
    return;
  }

  while((fgets(line, BUFFER, status)) != NULL) {
    if (strncmp(line, "Name:", 5) == 0) {
      position = line + 5;

      while(*position++ == ' ');
      strncpy(command, position, BUFFER - 1);
      command[BUFFER - 1] = '\0';
      commandSeen = 1;
    }

    if (strncmp(line, "Uid:", 4) == 0) {
      processUid = strtol(line + 4, NULL, 10);
      uidSeen = 1;
    }

    if (uidSeen && commandSeen) {
      break;
    }
  }

  if (processUid == uid) {
    printf("PID: %s, COMMAND: %s\n", pid, command);
  }
}
