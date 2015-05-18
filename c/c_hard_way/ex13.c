#include <stdio.h>

int main(int argc, char *argv[])
{
  if (argc < 2) {
    printf("You must have at leats one argument.\n");
    return 1;
  }

  int i = 0;

  for (i = 0; argv[1][i] != '\0'; i++) {
    switch (argv[1][i]) {
      case 'a':
      case 'A':
        printf("%d: 'A'\n", i);
      break;

      case 'e':
      case 'E':
        printf("%d: 'E'\n", i);
      break;

      case 'i':
      case 'I':
        printf("%d: 'I'\n", i);
      break;

      case 'o':
      case 'O':
        printf("%d: 'O'\n", i);
      break;

      case 'u':
      case 'U':
        printf("%d: 'U'\n", i);
      break;

      default:
        printf("%d: %c is not a vowel\n", i, argv[1][i]);
    }
  }

  return 0;
}
