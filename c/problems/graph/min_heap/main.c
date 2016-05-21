#include "min_heap.h"

int main(int argc, char *argv[]) {
  Heap heap = init(10);

  insert(&heap, 12);
  insert(&heap, 22);
  insert(&heap, 32);
  insert(&heap, 42);
  insert(&heap, 52);
  insert(&heap, 62);
  insert(&heap, 72);
  insert(&heap, 82);
  insert(&heap, 92);
  insert(&heap, 15);
  insert(&heap, 7);
  insert(&heap, 5);
  insert(&heap, 2);

  printf("%d\n", delete(&heap));
  printf("%d\n", delete(&heap));
  printf("%d\n", delete(&heap));
  printf("%d\n", delete(&heap));
  printf("%d\n", delete(&heap));
  printf("%d\n", delete(&heap));

  return 0;
};
