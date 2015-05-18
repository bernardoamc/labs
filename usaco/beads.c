/*
ID: bernard8
LANG: C
TASK: beads
*/

#include <stdio.h>
#include <stdlib.h>

typedef struct bead {
  struct bead *previous;
  struct bead *next;
  int type;
} Bead;

Bead * init(int);
Bead * add(Bead *, Bead *, int);
int search(Bead *, Bead *);

int main(void) {
  FILE *fin  = fopen ("beads.in", "r");
  FILE *fout = fopen ("beads.out", "w");
  Bead *root, *current = NULL;
  int i, type, max, local, quantity;

  max = 1;

  fscanf(fin, "%d ", &quantity);
  type = fgetc(fin);

  root = init(type);

  for(i = 0; i < (quantity - 1); ++i) {
    type = fgetc(fin);
    current = add(root, current, type);
  }

  for(i = 0; i < quantity; ++i) {
    current = root;

    if(current->type != current->next->type) {
      local = search(current, current->next);
    }

    if (local > max) {
      max = local;
    }

    root = root->next;
  }

  fprintf (fout, "%d\n", max);

  return 0;
}

Bead * init(int type) {
  Bead *bead = malloc(sizeof(Bead));

  if(bead == NULL) {
    printf("Error trying to init a bead");
    exit(1);
  }

  bead->previous = NULL;
  bead->next = NULL;
  bead->type = type;

  return bead;
}

Bead * add(Bead *root, Bead *current, int type) {
  Bead *bead = init(type);

  root->previous = bead;
  bead->next = root;

  if(!current) {
    bead->previous = root;
    root->next = bead;
  } else {
    bead->previous = current;
    current->next = bead;
  }

  return bead;
}

int search(Bead *left, Bead *right) {
  int lcount, rcount;
  int ltype = left->type;
  int rtype = right->type;

  lcount = rcount = 1;

  if (ltype == 'w') {
    if (rtype == 'r') {
      ltype = 'b';
    } else {
      ltype = 'r';
    }
  }

  if (rtype == 'w') {
    if (ltype == 'r') {
      rtype = 'b';
    } else {
      rtype = 'r';
    }
  }

  while(left->previous != right) {
    if (ltype == left->previous->type || left->previous->type == 'w') {
      lcount++;
    } else {
      break;
    }

    left = left->previous;
  }

  while(right->next != left) {
    if (rtype == right->next->type || right->next->type == 'w') {
      rcount++;
    } else {
      break;
    }

    right = right->next;
  }

  return (lcount + rcount);
}
