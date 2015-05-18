/*
 * Write a program to show that if the evp argument to timer_create() is
 * specified as NULL, then this is equivalent to specifying evp as a pointer
 * to a sigevent structure with sigev_notify set to SIGEV_SIGNAL, sigev_signo
 * set to SIGALRM, and si_value.sival_int set to the timer ID.
 *
 * Usage:
 *
 *   ./timer_create
*/

#define _XOPEN_SOURCE 700

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <time.h>
#include <sys/time.h>

void helpAndLeave(const char *progname, int status);
void pexit(const char *fCall);
void timerHandler(int, siginfo_t *, void *);

static timer_t timerId;

int main(int argc, char *argv[]) {
  if (argc != 1) {
    helpAndLeave(argv[0], EXIT_FAILURE);
  }

  struct sigaction act;
  struct itimerspec setTime;

  if (sigemptyset(&act.sa_mask) == -1) {
    pexit("sigemptyset");
  }

  act.sa_flags = SA_SIGINFO;
  act.sa_sigaction = timerHandler;

  if (sigaction(SIGALRM, &act, NULL) == -1) {
    pexit("sigaction");
  }

  if (timer_create(CLOCK_REALTIME, NULL, &timerId) == -1) {
    pexit("timer_create");
  }

  setTime.it_interval.tv_sec = 0;
  setTime.it_interval.tv_nsec = 0;

  setTime.it_value.tv_sec = 5;
  setTime.it_value.tv_nsec = 0;

  if (timer_settime(timerId, 0, &setTime, NULL) == -1) {
    pexit("timer_settime");
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

void timerHandler(int signal, siginfo_t *info, void *context) {
  if (signal == SIGALRM) {
    printf("Signal: SIGARLM\n");

    if ((long) timerId == (long) info->si_value.sival_int) {
      printf("Same timer ID, which is: %ld\n", (long) timerId);
    }
  }
}
