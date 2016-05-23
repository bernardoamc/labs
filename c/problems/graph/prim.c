/*
 *  Prim's algorithm gives us a Minimum Spanning Tree (MST).
 *  A minimum weight connected graph with no cycles.
 *
 *  How it works: https://www.youtube.com/watch?v=cplfcGZmX7I
 *
 *  To store the graph we have (that I know) two strategies:
 *
 *  1- An adjacency  matrix, that is simply represented as a
 *  two dimensional array (matrix[nodes][nodes]).
 *
 *  2- An adjacency list, that is represented as an array of linked
 *  lists. It's something like: AdjacencyList *head, this *head will
 *  be initialized with the same size as nodes in our graph and each
 *  position is just a pointer to the start of a linked list
 *  representing the edges of each node.
 *
 *  Which representation is better?
 *
 *  The adjacency list uses way less memory and is more efficient regarding
 *  the search part of the algorithm, where you have to find all edges from
 *  a vertice. With the adjacency list you already have the edges, with the
 *  adjacency matrix you have to loop through the entire row to find the edges.
 *
 *  Data structures to solve the problem:
 *  - An array to store the visited vertices.
 *  - An array to represent each vertice parent (given the chosen path).
 *  - An array to represent the weight to reach each vertice.
 *  - * We can also use a heap to always pick the lowest edge weight.
 *
 *  The input is the following:
 *  nodes edges
 *  node node weight  }
 *  ...               | Each line is an edge, this section has <edges> lines.
 *  node node weight  }
 *  starting_node
 *
 *  The output represents the total weight of the generated graph.
 *
 *  Example of input:
 *
 *     5 6
 *     1 2 3
 *     1 3 4
 *     4 2 6
 *     5 2 2
 *     2 3 5
 *     3 5 7
 *     1
 *
 *  Output: 15
 *
*/

#include <stdio.h>
#include <stdlib.h>

#define INITIAL_HEAP_SIZE 50
#define LCHILD(x) 2 * x + 1
#define RCHILD(x) 2 * x + 2
#define PARENT(x) (x - 1) / 2

typedef struct node {
  int vertice;
  int cost;
} Node ;

typedef struct heap {
  int max_size;
  int current_size;
  Node *elem;
} Heap ;

Heap init(int size);

int node_smaller_than_parent(Heap *heap, Node *node, int node_index);
void insert(Heap *heap, int vertice, int cost);

void swap(Node *n1, Node *n2);
void heapify(Heap *heap, int i);
int get_smaller_node(Heap *heap, int node_1, int node_2);
Node delete(Heap *heap);

int main(int argc, char *argv[]) {
  int nodes, edges, start_node, node_1, node_2, weight;

  scanf("%d %d", &nodes, &edges);

  int **matrix = malloc(nodes * sizeof(int *));
  int *visited = calloc(nodes, sizeof(int));
  int *cost = calloc(nodes, sizeof(int));
  Heap heap = init(INITIAL_HEAP_SIZE);

  for(int i = 0; i < nodes; i++) {
    matrix[i] = calloc(nodes, sizeof(int));
  }

  while(edges--) {
    scanf("%d %d %d", &node_1, &node_2, &weight);
    node_1--;
    node_2--;

    // Set weight or replace by a smaller value.
    if(!matrix[node_1][node_2] || weight < matrix[node_1][node_2]) {
      matrix[node_1][node_2] = weight;
      matrix[node_2][node_1] = weight;
    }
  }

  scanf("%d", &start_node);
  start_node--;
  insert(&heap, start_node, 0);

  while(heap.current_size) {
    Node min_node = delete(&heap);
    if (visited[min_node.vertice]) continue;

    cost[min_node.vertice] = min_node.cost;
    visited[min_node.vertice] = 1;

    for(int node = 0; node < nodes; node++) {
      if (matrix[min_node.vertice][node] && !visited[node]) {
        insert(&heap, node, matrix[min_node.vertice][node]);
      }
    }
  }

  weight = 0;
  for(int node = 0; node < nodes; node++) {
    weight += cost[node];
  }

  printf("%d\n", weight);

  return 0;
}

Heap init(int size) {
  Heap heap;
  heap.current_size = 0;
  heap.max_size = size;
  heap.elem = malloc(size * sizeof(Node));

  return heap;
}

int node_smaller_than_parent(Heap *heap, Node *node, int node_index) {
  return (node_index &&
          node->cost < heap->elem[PARENT(node_index)].cost);
}

void insert(Heap *heap, int vertice, int cost) {
  if(heap->current_size == heap->max_size) {
    heap->max_size *= 2;
    heap->elem = realloc(heap->elem, heap->max_size * sizeof(Node));
  }

  Node node = { .vertice = vertice, .cost = cost };

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

Node delete(Heap *heap) {
  Node min = heap->elem[0];

  heap->current_size--;
  heap->elem[0] = heap->elem[heap->current_size];
  heapify(heap, 0);

  return min;
}
