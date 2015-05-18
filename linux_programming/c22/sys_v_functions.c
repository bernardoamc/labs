/*
 * Implement the System V functions sigset(), sighold(), sigrelse(), sigignore()
 * and sigpause() using the POSIX signal API. *
 *
 * Usage:
 *
 *   ./sys_v_functions
*/

#define _XOPEN_SOURCE 700

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>

typedef void (*sighandler_t)(int);

void helpAndLeave(const char *progname, int status);
void pexit(const char *fCall);

sighandler_t _sigset(int sig, sighandler_t handler);
int _sighold(int);
int _sigrelse(int);
int _sigignore(int);
int _sigpause(int);

int main(int argc, char *argv[]) {
  if (argc != 1) {
    helpAndLeave(argv[0], EXIT_FAILURE);
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

sighandler_t _sigset(int sig, sighandler_t handler) {
  sigset_t removeFromSet;
  struct sigaction newAct, oldAct;

  if (handler == SIG_HOLD) {
    _sighold(sig);

    return SIG_HOLD;
  } else {
    newAct.sa_handler = handler;

    if (sigaction(sig, &newAct, &oldAct) == -1) {
      return -1;
    }
  }

  return oldAct.sa_handler;
}

int _sighold(int sig) {
  sigset_t addToSet;

  sigemptyset(&addToSet);
  sigaddset(&addToSet, sig);

  return sigprocmask(SIG_BLOCK, &addToSet, NULL);
}

int _sigrelse(int sig) {
  sigset_t removeFromSet;

  sigemptyset(&removeFromSet);
  sigaddset(&removeFromSet, sig);

  return sigprocmask(SIG_UNBLOCK, &removeFromSet, NULL);
}

int _sigignore(int sig) {
  struct sigaction act;

  act.sa_handler = SIG_IGN;

  return sigaction(sig, &act, NULL);
}

int _sigpause(int sig) {
  sigset_t currentMask;

  sigprocmask(SIG_BLOCK, NULL, &currentMask);
  sigdelset(&currentMask, sig);

  sigsuspend(&currentMask);
}
