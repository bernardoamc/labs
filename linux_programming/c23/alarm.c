/*
 * Implement alarm() in terms of settimer()
 *
 * Usage:
 *
 *   ./alarm
*/

#define _XOPEN_SOURCE 700

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/time.h>

void helpAndLeave(const char *progname, int status);
void pexit(const char *fCall);
int _alarm(int);
void timerHandler(int);

static volatile sig_atomic_t gotAlarm = 0;

int main(int argc, char *argv[]) {
  if (argc != 1) {
    helpAndLeave(argv[0], EXIT_FAILURE);
  }

  int previousTimer;
  struct sigaction act;

  if (sigemptyset(&act.sa_mask) == -1) {
    pexit("sigemptyset");
  }

  act.sa_flags = 0;
  act.sa_handler = timerHandler;

  if (sigaction(SIGALRM, &act, NULL) == -1) {
    pexit("sigaction");
  }

  if((previousTimer = _alarm(5)) == -1) {
    pexit("_alarm");
  }

  pause();

  if(gotAlarm) {
    printf("Alarm!!!! Seconds remaining of previous timer: %d\n", previousTimer);
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

int _alarm(int seconds) {
  struct itimerval setTime, currentTime;

  setTime.it_interval.tv_sec = 0;
  setTime.it_interval.tv_usec = 0;

  setTime.it_value.tv_sec = seconds;
  setTime.it_value.tv_usec = 0;

  if (setitimer(ITIMER_REAL, &setTime, &currentTime) == -1) {
    return 0; // What should I return if this fails? Alarm does not fail. :/
  }

  return currentTime.it_value.tv_sec;
}

void timerHandler(int signal) {
  gotAlarm = 1;
}
