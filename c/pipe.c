#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int main(void) {
  int returnValue = 0;
  int n = 0;
  int fd[2];
  pid_t pid;
  char line[100];

  if (pipe(fd) < 0) {
    perror("pipe");
    exit(1);
  }

  switch(pid = fork()) {
  case -1:
    perror("fork");  /* fork failed */
    exit(1);         /* parent exits */

  case 0: // CHILD
    printf("CHILD: Closing the write FD of the PIPE!\n");
    n = read(fd[0], line, 100);
    printf("%s", line);
    printf("CHILD: Exiting child!!\n");
    exit(0);

  default: // PARENT
    printf("PARENT: Closing the reading FD of the PIPE!\n");
    close(fd[0]);

    write(fd[1], "hello world\n", 12);
    write(fd[1], "this is cool\n", 13);

    wait(&returnValue);
    printf("PARENT: My child's exit status is: %d\n", WEXITSTATUS(returnValue));
    printf("PARENT: Exiting main program!\n");
  }

  return 0;
}
