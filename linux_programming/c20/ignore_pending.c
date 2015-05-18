/*
 * Write a program that shows that when the disposition of a pending signal
 * is changed to be SIG_IGN, the program never sees (catches) the signal.
 *
 * Usage:
 *
 *  ./ignore_pending
*/

#define _XOPEN_SOURCE 700

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

void helpAndLeave(const char *progname, int status);
void pexit(const char *fCall);

int main(int argc, char *argv[]) {
  if (argc != 1) {
    helpAndLeave(argv[0], EXIT_FAILURE);
  }

  sigset_t pendingSet, blockedSet;

  sigemptyset(&blockedSet);
  sigaddset(&blockedSet, SIGINT);

  if (sigprocmask(SIG_BLOCK, &blockedSet, NULL) == -1) {
    pexit("sigprocmask");
  }

  raise(SIGINT);

  if (sigpending(&pendingSet) == -1) {
    pexit("sigpending");
  }

  if (sigismember(&pendingSet, SIGINT)) {
    printf("SIGINT is in the pending list.\n");
  } else {
    printf("SIGINT is not in the pending list (this should be wrong).\n");
  }

  if (signal(SIGINT, SIG_IGN) == SIG_ERR) {
    pexit("signal");
  }

  if (sigprocmask(SIG_UNBLOCK, &blockedSet, NULL) == -1) {
    pexit("sigprocmask");
  }

  if (sigpending(&pendingSet) == -1) {
    pexit("sigpending");
  }

  if (sigismember(&pendingSet, SIGINT)) {
    printf("SIGINT is in the pending list (this should be wrong).\n");
  } else {
    printf("SIGINT signal is not in the pending list.\n");
  }

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
