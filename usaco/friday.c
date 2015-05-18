/*
ID: bernard8
LANG: C
TASK: friday
*/

#include <stdio.h>

typedef enum { SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY } week_days;

int main(void) {
  FILE *fin  = fopen ("friday.in", "r");
  FILE *fout = fopen ("friday.out", "w");
  int fridays[7] = {0};
  int month_days[] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
  int i, j, year, years, week_day;

  year = 1900;
  week_day = MONDAY;

  fscanf (fin, "%d", &years);  /* the two input integers */

  years += year;

  for (year = 1900; year < years; ++year) {
    if (year % 400 == 0)
      month_days[1] = 29;
    else if (year % 100 == 0)
      month_days[1] = 28;
    else if (year % 4 == 0 )
      month_days[1] = 29;
    else
      month_days[1] = 28;

    for (i = 0; i < 12; ++i) {
      for (j = 0; j < month_days[i]; ++j) {
        week_day = week_day % 7;

        if (j == 13) fridays[week_day]++;

        ++week_day;
      }
    }
  }

  fprintf (fout, "%d ", fridays[SUNDAY]);
  fprintf (fout, "%d ", fridays[MONDAY]);
  fprintf (fout, "%d ", fridays[TUESDAY]);
  fprintf (fout, "%d ", fridays[WEDNESDAY]);
  fprintf (fout, "%d ", fridays[THURSDAY]);
  fprintf (fout, "%d ", fridays[FRIDAY]);
  fprintf (fout, "%d\n", fridays[SATURDAY]);

  return 0;
}
