/*
 *  Reimplementing unsetenv() and setenv() with getenv() and putenv()
 *
 *  Errors: http://man7.org/linux/man-pages/man3/errno.3.html
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

extern char **environ;

void environment_list(void);
int _unsetenv(const char *);
int _setenv(const char *, const char *, int);

int main(int argc, char *argv[]) {
  printf("Current environment list:\n");
  environment_list();

  _setenv("LPI", "FAILURE", 0);
  environment_list();

  _setenv("LPI", "SUCCESS", 1);
  environment_list();

  _setenv("LPI", "FAILURE", 0);
  environment_list();

  _unsetenv("LPI");
  environment_list();

  exit(EXIT_SUCCESS);
}

void environment_list(void) {
  char **env_pos;

  for (env_pos = environ; *env_pos != NULL; env_pos++) {
    puts(*env_pos);
  }

  printf("-------------------------------------------------------------\n\n\n");
}

int _unsetenv(const char *name) {
  char **env_pos, **shift_pos;
  size_t len;

  if (name == NULL || *name == '\0' || strchr(name, '=') != NULL) {
    errno = EINVAL;
    return -1;
  }

  len = strlen(name);
  env_pos = environ;

  while(*env_pos != NULL) {
    if (strncmp(*env_pos, name, len) == 0 && (*env_pos)[len] == '=') {
      for (shift_pos = env_pos; *shift_pos != NULL; shift_pos++) {
        *shift_pos = *(shift_pos + 1);
      }
    } else {
      env_pos++;
    }
  }

  return 0;
}

int _setenv(const char *name, const char *value, int overwrite) {
  char *env_var = NULL;
  size_t env_len = 0;

  if (name == NULL || *name == '\0' || strchr(name, '=') != NULL) {
    errno = EINVAL;
    return -1;
  }

  if (getenv(name) != NULL) {
    if (overwrite) {
      _unsetenv(name);
    } else {
      errno = EPERM;
      return -1;
    }
  }

  env_len = strlen(name) + strlen("=") + strlen(value) + 1; // For the '\0'
  env_var = malloc(env_len);

  if (!env_var) {
    return -1;
  }

  strcpy(env_var, name);
  strcat(env_var, "=");
  strcat(env_var, value);

  if (putenv(env_var) == 0) {
    return 0;
  } else {
    return -1;
  }
}
