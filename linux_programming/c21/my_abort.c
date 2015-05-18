/*
 *
 * The abort() function terminates the calling process by raising a SIGABRT
 * signal. The default action for SIGABRT is to produce a core dump file and
 * terminate the process. The core dump file can then be used within a debugger
 * to examine the state of the program at the time of the abort() call.
 *
 * Usage:
 *
 *  ./my_abort
*/

#define _XOPEN_SOURCE 700

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>

void helpAndLeave(const char *progname, int status);
void pexit(const char *fCall);
void myAbort(void);

int main(int argc, char *argv[]) {
  if (argc != 1) {
    helpAndLeave(argv[0], EXIT_FAILURE);
  }

  myAbort();

  exit(EXIT_SUCCESS);
}

void myAbort(void) {
  sigset_t unblockSet;
  struct sigaction currentHandler;

  sigemptyset(&unblockSet);
  sigaddset(&unblockSet, SIGABRT);

  if (sigprocmask(SIG_UNBLOCK, &unblockSet, NULL) == -1) {
    pexit("sigprocmask");
  }

  if (sigaction(SIGABRT, NULL, &currentHandler) == -1) {
    pexit("sigaction");
  }

  if (currentHandler.sa_handler == SIG_IGN) {
    currentHandler.sa_handler = SIG_DFL;

    if (sigaction(SIGABRT, &currentHandler, NULL) == -1) {
      pexit("sigaction");
    }
  }

  if (currentHandler.sa_handler != SIG_DFL) {
    raise(SIGABRT);

    currentHandler.sa_handler = SIG_DFL;

    if (sigaction(SIGABRT, &currentHandler, NULL) == -1) {
      pexit("sigaction");
    }
  }

  if (fflush(stdout) == EOF || fflush(stderr) == EOF) {
    pexit("fflush");
  }

  if (close(STDOUT_FILENO) == -1 || close(STDERR_FILENO) == -1) {
    pexit("close");
  }

  raise(SIGABRT);
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
