#ifndef _MIN_HEAP
#define _MIN_HEAP

#include <stdio.h>
#include <stdlib.h>

#define LCHILD(x) 2 * x + 1
#define RCHILD(x) 2 * x + 2
#define PARENT(x) (x - 1) / 2

typedef struct node {
  int cost;
} Node ;

typedef struct heap {
  int max_size;
  int current_size;
  Node *elem;
} Heap ;

Heap init(int size);

int node_smaller_than_parent(Heap *heap, Node *node, int node_index);
void insert(Heap *heap, int cost);

void swap(Node *n1, Node *n2);
void heapify(Heap *heap, int i);
int get_smaller_node(Heap *heap, int node_1, int node_2);
int delete(Heap *heap);

#endif
