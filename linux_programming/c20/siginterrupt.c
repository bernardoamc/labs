/*
 * Implement siginterrupt() using sigaction().
 *
 * Usage:
 *
 *  ./siginterrupt
*/

#define _XOPEN_SOURCE 700

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

void helpAndLeave(const char *progname, int status);
void pexit(const char *fCall);
int interrupt(int, int);
void handler(int);

int main(int argc, char *argv[]) {
  if (argc != 1) {
    helpAndLeave(argv[0], EXIT_FAILURE);
  }

  // Do nothing because i'm feeling lazy \o/

  exit(EXIT_SUCCESS);
}

void helpAndLeave(const char *progname, int status) {
  FILE *stream = stderr;

  if (status == EXIT_SUCCESS) {
    stream = stdout;
  }

  fprintf(stream, "Usage: %s", progname);
  exit(status);
}

void pexit(const char *fCall) {
  perror(fCall);
  exit(EXIT_FAILURE);
}

int interrupt(int signal, int flag) {
  struct sigaction act;

  if (sigaction(SIGINT, NULL, &act) == -1) {
    return -1;
  }

  if (flag) {
    act.sa_flags &= ~SA_RESTART;
  } else {
    act.sa_flags &= SA_RESTART;
  }

   if (sigaction(SIGINT, &act, NULL) == -1) {
    return -1;
  }

  return 0;
}

void handler(int signal) {
  printf("OMG, INTERRUPTION!!!!!\n");
}
