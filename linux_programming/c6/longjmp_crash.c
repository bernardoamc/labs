#include <stdio.h>
#include <stdlib.h>
#include <setjmp.h>

static jmp_buf env;

static void crash(void);
static void setCrash(void);
static void invokeCrash(void);

int main(int argc, char *argv[]) {
  crash();
  invokeCrash();

  exit(EXIT_SUCCESS);
}

static void crash() {
  printf("Inside crash, let's set a crash!\n");
  setCrash();
}

static void setCrash() {
  int age = 27;

  printf("Inside setCrash()\n");

  if (setjmp(env) == 0) {
    printf("It's a setjmp!\n");
  } else {
    printf("It's a longjmp with age %d!\n", age);
  }
}

static void invokeCrash() {
  printf("How about we crash now? :)\n");

  longjmp(env, 5);
}
