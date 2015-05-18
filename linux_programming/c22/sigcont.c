/*
 * Section 22.2 noted that if a stopped process that has established a handler
 * for and blocked SIGCONT is later resumed as a consequence of receiving a
 * SIGCONT, then the handler is invoked only when SIGCONT is unblocked. Write
 * a program to verify this. Recall that a process can be stopped by typing
 * the terminal suspend character (usually Control-Z) and can be sent a SIGCONT
 * signal using the command kill –CONT (or implicitly, using the shell fg command).
 *
 * Usage:
 *
 *   ./sigcont
*/

#define _XOPEN_SOURCE 700

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>
#include <time.h>

void helpAndLeave(const char *progname, int status);
void pexit(const char *fCall);
void contHandler(int);

int main(int argc, char *argv[]) {
  if (argc != 1) {
    helpAndLeave(argv[0], EXIT_FAILURE);
  }

  printf("%s: PID = %ld\n", argv[0], (long) getpid());

  time_t start;
  sigset_t blocked;
  struct sigaction act;

  if (sigemptyset(&blocked) == -1) {
    pexit("sigemptyset");
  }

  if (sigaddset(&blocked, SIGCONT) == -1) {
    pexit("sigaddset");
  }

  if (sigprocmask(SIG_BLOCK, &blocked, NULL) == -1) {
    pexit("sigprocmask");
  }

  if (sigemptyset(&act.sa_mask) == -1) {
    pexit("sigemptyset");
  }

  act.sa_flags = 0;
  act.sa_handler = contHandler;

  if (sigaction(SIGCONT, &act, NULL) == -1) {
    pexit("sigaction");
  }

  printf("Press CTRL + Z and type kill -CONT %ld\n", (long) getpid());

  for (start = time(NULL); time(NULL) < start + 15;);

  printf("Unblocking SIGCONT\n");

  if (sigprocmask(SIG_UNBLOCK, &blocked, NULL) == -1) {
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

void contHandler(int sig) {
  printf("SIGCONT called!\n");
}
