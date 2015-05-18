/*
    Implementing getpwnam() using setpwent(), getpwent(), and endpwent().
*/

#include <stdio.h>
#include <stdlib.h>
#include <pwd.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

struct passwd * _getpwnam(const char *name);

int main(int argc, char *argv[]) {
  struct passwd *record;

  record = _getpwnam("bernardo");

  if (record != NULL) {
    printf("User %s found!\n", record->pw_name);
  }

  record = _getpwnam("test");

  if (record != NULL) {
    printf("User %s found!\n", record->pw_name);
  }

  exit(EXIT_SUCCESS);
}

struct passwd * _getpwnam(const char *name) {
  struct passwd *record;
  size_t maxUsernameLength;

  maxUsernameLength = sysconf(_SC_LOGIN_NAME_MAX);

  if (maxUsernameLength == -1) {
    maxUsernameLength = 256; /* make a guess */
  }

  setpwent();

  while ((record = getpwent()) != NULL) {
    if (strncmp(record->pw_name, name, maxUsernameLength) == 0) {
      endpwent();

      return record;
    }
  }

  endpwent();

  return NULL;
}
