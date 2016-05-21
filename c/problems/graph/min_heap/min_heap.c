#include "min_heap.h"

Heap init(int size) {
  Heap heap;
  heap.current_size = 0;
  heap.max_size = size;
  heap.elem = malloc(size * sizeof(Node));

  if (!heap.elem) {
    exit(1);
  }

  return heap;
}

int node_smaller_than_parent(Heap *heap, Node *node, int node_index) {
  return (node_index &&
          node->cost < heap->elem[PARENT(node_index)].cost);
}

void insert(Heap *heap, int cost) {
  if(heap->current_size == heap->max_size) {
    heap->max_size *= 2;
    heap->elem = realloc(heap->elem, heap->max_size * sizeof(Node));
  }

  if (!heap->elem) {
    exit(1);
  }

  Node node = { .cost = cost };

  int node_index = heap->current_size;
  heap->current_size++;

  while(node_smaller_than_parent(heap, &node, node_index)) {
    heap->elem[node_index] = heap->elem[PARENT(node_index)];
    node_index = PARENT(node_index);
  }

  heap->elem[node_index] = node;
}

void swap(Node *n1, Node *n2) {
  Node temp = *n1;
  *n1 = *n2;
  *n2 = temp;
}

int get_smaller_node(Heap *heap, int node_1, int node_2) {
  if (heap->elem[node_1].cost < heap->elem[node_2].cost) {
    return node_1;
  }

  return node_2;
}

void heapify(Heap *heap, int node_index) {
  int smallest = node_index;

  if (LCHILD(node_index) < heap->current_size) {
    smallest = get_smaller_node(heap, LCHILD(node_index), smallest);
  }

  if (RCHILD(node_index) < heap->current_size) {
    smallest = get_smaller_node(heap, RCHILD(node_index), smallest);
  }

  if(smallest != node_index) {
    swap(&(heap->elem[node_index]), &(heap->elem[smallest]));
    heapify(heap, smallest);
  }
}

int delete(Heap *heap) {
  int cost = -1;

  if(heap->current_size) {
    cost = heap->elem[0].cost;
    heap->current_size--;
    heap->elem[0] = heap->elem[heap->current_size];
    heapify(heap, 0);
  }

  return cost;
}
