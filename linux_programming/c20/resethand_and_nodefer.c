/*
 * Write programs that verify the effect of the SA_RESETHAND and SA_NODEFER
 * flags when establishing a signal handler with sigaction().
 *
 * NODEFER:
 * When a signal is caught it is added to the process signal mask automatically
 * while the handler is being executed. The NODEFER flag stop this from
 * happening, so if the same signal is caught during the handler execution
 * it will stop the handler and invoke a new one. Just after the second handler
 * is finished that the first one will continue execution.
 *
 * RESETHAND
 * When a signal is caught this flag reset its disposition to the default.
 * To be clear: The handler we implemented will be executed only once, after
 * that the signal will do its default action.
 *
 * Usage:
 *
 *  ./resethand_and_nodefer
*/

#define _XOPEN_SOURCE 700

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

void helpAndLeave(const char *progname, int status);
void pexit(const char *fCall);
void deferHandler(int);
void resetHandler(int);

int main(int argc, char *argv[]) {
  if (argc != 1) {
    helpAndLeave(argv[0], EXIT_FAILURE);
  }

  struct sigaction act;

  // NODEFER
  act.sa_handler = deferHandler;
  act.sa_flags = SA_NODEFER;

  if (sigaction(SIGINT, &act, NULL) == -1) {
    pexit("sigaction");
  }

  printf("Type CTRL+C to see NODEFER\n");
  printf("Type CTRL+\\ to see RESETHAND\n");

  // RESETHAND
  act.sa_handler = resetHandler;
  act.sa_flags = SA_RESETHAND;

  if (sigaction(SIGQUIT, &act, NULL) == -1) {
    pexit("sigaction");
  }

  pause();

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

void deferHandler(int signal) {
  static int times = 0;

  times++;

  printf("Hello, i'm being interrupted %d times! :D\n", times);
  sleep(5);
  printf("But not anymore! (%d)\n", times);
}

void resetHandler(int signal) {
  printf("I will interrupt the interruption just once, after that it's game over!\n");
}
