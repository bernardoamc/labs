#include <stdio.h>
#include <stdlib.h>
#include "input.h"
#include "trie.h"

int main(int argc, char *argv[])
{
  int command;
  char *name;
  Trie initial;

  TrieInitialize(&initial);

  do {
    printf(
      "\nAvaliable commands\n\n"
      "1 - Insert\n"
      "2 - Present\n"
      "0 - Quit\n\n"
    );

    printf("Your command: ");
    command = GetInt();

    printf("\n");

    switch (command) {
      case 1:
        printf("Insert a name: ");
        name = GetString();
        TrieInsert(&initial, name);
        free(name);
      break;
      case 2:
        printf("Search a name: ");
        name = GetString();

        if (TriePresent(&initial, name)) {
          printf("name found!\n");
        } else {
          printf("not found!\n");
        }

        free(name);
      break;
    }

  } while (command != 0);

  return 0;
}
