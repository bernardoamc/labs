/*
 *
 * If both a realtime and a standard signal are pending for a process, SUSv3
 * leaves it unspecified which is delivered first. Write a program that shows
 * what Linux does in this case. (Have the program set up a handler for all
 * signals, block signals for a period time so that you can send various
 * signals to it, and then unblock all signals.) *
 *
 * Usage:
 *
 *  ./std_real_signals.c
*/

#define _XOPEN_SOURCE 700

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>
#include <limits.h>

void helpAndLeave(const char *progname, int status);
void pexit(const char *fCall);
void handler(int);

int main(int argc, char *argv[]) {
  if (argc != 1) {
    helpAndLeave(argv[0], EXIT_FAILURE);
  }

  sigset_t blockAll;
  struct sigaction act;

  if (sigfillset(&blockAll) == -1) {
    pexit("sigfillset");
  }

  printf("Blocking all signals!\n");

  if (sigprocmask(SIG_BLOCK, &blockAll, NULL) == -1) {
    pexit("sigprocmask");
  }

  act.sa_flags = 0;
  act.sa_handler = handler;

  printf("Add handler to pertinent signals\n");

  if (sigaction(SIGINT, &act, NULL) == -1) {
    pexit("sigaction");
  }

  if (sigaction(SIGRTMIN + 2, &act, NULL) == -1) {
    pexit("sigaction");
  }

  if (sigaction(SIGRTMIN + 3, &act, NULL) == -1) {
    pexit("sigaction");
  }

  printf("Let's call some realtime and standard signals! :D\n");

  printf("Calling realtime signal: %d\n", SIGRTMIN + 3);
  raise(SIGRTMIN + 3);

  printf("Calling SIGINT\n");
  raise(SIGINT);

  printf("Calling realtime signal: %d\n", SIGRTMIN + 2);
  raise(SIGRTMIN + 2);

  printf("Unblocking all signals!\n");

  if (sigprocmask(SIG_UNBLOCK, &blockAll, NULL) == -1) {
    pexit("sigprocmask");
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

void handler(int sig) {
  printf("Signal %d called!\n", sig);
}
