/*
 *  Djikstra is used to find the shortest path between a vertice and
 *  all the other vertices on the graph.
 *
 *  Other algorithm related to the Shortest Route Path: Floyd Warshall
 *
 *  How it works: https://www.youtube.com/watch?v=8Ls1RqHCOPw
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
 *  adjacency matrix you have to loop through the entire vertice row to find
 *  the edges.
 *
 *  Data structures to solve the problem:
 *  - An array to store the visited vertices.
 *  - An array to represent the cost to reach each vertice.
 *  - We can use a heap to always pick the lowest vertice weight.
*/

#include <stdio.h>
#include <stdlib.h>

#define LCHILD(x) 2 * x + 1
#define RCHILD(x) 2 * x + 2
#define PARENT(x) (x - 1) / 2

typedef struct node {
  int from;
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
void insert(Heap *heap, int vertice, int cost, int from);

void swap(Node *n1, Node *n2);
void heapify(Heap *heap, int i);
int get_smaller_node(Heap *heap, int node_1, int node_2);
Node delete(Heap *heap);

int main() {
  int cases, nodes, edges, goal, node_1, node_2, edge_cost;

  scanf("%d", &cases);

  while(cases--) {
    scanf("%d %d", &nodes, &edges);

    int **matrix = malloc(nodes * sizeof(int *));
    int *cost = malloc(nodes * sizeof(int));
    int *finished = malloc(nodes * sizeof(int));
    Heap heap = init(nodes);

    for(int i = 0; i < nodes; i++) {
      matrix[i] = calloc(nodes, sizeof(int));
      cost[i] = -1;
      finished[i] = 0;
    }

    while(edges--) {
      scanf("%d %d %d", &node_1, &node_2, &edge_cost);
      node_1--;
      node_2--;

      if(!matrix[node_1][node_2] || edge_cost < matrix[node_1][node_2]) {
        matrix[node_1][node_2] = edge_cost;
        matrix[node_2][node_1] = edge_cost;
      }
    }

    scanf("%d", &goal);
    goal--;
    cost[goal] = 0;
    insert(&heap, goal, 0, goal);

    while(heap.current_size) {
      Node min_node = delete(&heap);
      if (finished[min_node.vertice]) continue;

      cost[min_node.vertice] = min_node.cost;
      finished[min_node.vertice] = 1;

      for(int node = 0; node < nodes; node++) {
        if (matrix[min_node.vertice][node] && !finished[node]) {
          int cost_from = cost[min_node.vertice] + matrix[min_node.vertice][node];
          insert(&heap, node, cost_from, min_node.vertice);
        }
      }
    }

    for(int node = 0; node < nodes; node++) {
      if (node != goal) {
        printf("%d ", cost[node]);
      }
    }

    printf("\n");

    for(int i = 0; i < nodes; i++) {
      free(matrix[i]);
    }

    free(heap.elem);
    free(finished);
    free(cost);
    free(matrix);
  }

    return 0;
}

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

void insert(Heap *heap, int vertice, int cost, int from) {
  if(heap->current_size == heap->max_size) {
    heap->max_size *= 2;
    heap->elem = realloc(heap->elem, heap->max_size * sizeof(Node));
  }

  if (!heap->elem) {
    exit(1);
  }

  Node node = { .from = from, .vertice = vertice, .cost = cost };

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
