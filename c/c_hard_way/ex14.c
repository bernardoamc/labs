#include <stdio.h>
#include <ctype.h>

void print_arguments(int argc, char *argv[]);
void print_letters(char arg[]);

int main(int argc, char *argv[])
{
  print_arguments(argc, argv);

  return 0;
}

void print_arguments(int argc, char *argv[])
{
  int i = 0;

  for (i = 0; i < argc; i++) {
    print_letters(argv[i]);
  }
}

void print_letters(char arg[])
{
  int i = 0;

  for (i = 0; arg[i] != '\0'; i++) {
    char ch = arg[i];

    if (isalpha(ch) || isblank(ch)) {
      printf("'%c' == %d ", ch, ch);
    }
  }

  printf("\n");
}

