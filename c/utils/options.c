#include <stdio.h>
#include <stdlib.h>
#include "input.h"

int main(int argc, char *argv[])
{
  int command;

  do {
    printf(
      "\nAvaliable commands\n\n"
      "1 - Insert\n"
      "2 - Delete\n"
      "3 - Search\n"
      "0 - Quit\n\n"
    );

    printf("Your command: ");

    command = GetInt();

    printf("\n");

    switch (command) {
      case 1: printf("insert()\n"); break;
      case 2: printf("delete()\n"); break;
      case 3: printf("search()\n"); break;
      default: printf("invalid()\n"); break;
    }

  } while (command != 0);

  return 0;
}
