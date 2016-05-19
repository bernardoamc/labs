/*
 * Find the shortest path between all nodes and a given node (called goal),
 * if there is no path between a node and the goal the final cost will be -1.
 * Each edge has a cost of 6.
 *
 * The input consists of integers in the form:
 *
 * cases
 * nodes edges
 * node_x node_y
 * node_x node_y
 * ...
 * goal
 *
 * Where after the tuple (node, edges) we have a number of lines equal
 * to edges representing each edge in the graph between node_x and node_y.
*/

#include <stdio.h>
#include <stdlib.h>

typedef struct node
{
  int data;
  int step;
  struct node* next;
} Node;

Node* enqueue(Node* fifo, int data, int step);
Node* dequeue(Node* fifo, int *data, int *step);

int main() {
  int cases, nodes, edges, goal, node_1, node_2;
  int edge_cost = 6;

  scanf("%d", &cases);

  while(cases--) {
    scanf("%d %d", &nodes, &edges);

    int **matrix = malloc(nodes * sizeof(int *));
    int *visited = calloc(nodes, sizeof(int));
    int *cost = malloc(nodes * sizeof(int));
    Node *queue = NULL;

    for(int i = 0; i < nodes; i++) {
      matrix[i] = calloc(nodes, sizeof(int));
      cost[i] = -1;
    }

    while(edges--) {
      scanf("%d %d", &node_1, &node_2);
      matrix[node_1][node_2] = 1;
      matrix[node_2][node_1] = 1;
    }

    scanf("%d", &goal);

    queue = enqueue(queue, goal, 0);
    visited[goal] = 1;

    while(queue != NULL) {
      int current_node, current_step;
      queue = dequeue(queue, &current_node, &current_step);

      for(int node = 0; node < nodes; node++) {
        if (matrix[current_node][node] && !visited[node]) {
          queue = enqueue(queue, node, current_step + 1);
          cost[node] = (current_step + 1) * edge_cost;
          visited[node] = 1;
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

    free(visited);
    free(cost);
    free(matrix);
  }

    return 0;
}

Node* enqueue(Node* queue, int data, int step) {
  Node *tmp = malloc(sizeof(Node));
  Node *rear = queue;

  tmp->data = data;
  tmp->step = step;
  tmp->next = NULL;

  if (queue == NULL) {
    queue = tmp;
  } else {
    while (rear->next != NULL) rear = rear->next;
    rear->next = tmp;
  }

  return queue;
}

Node* dequeue(Node *queue, int *element, int *step)
{
  Node* tmp = queue;

  *element = queue->data;
  *step = queue->step;

  queue = queue->next;

  free(tmp);

  return queue;
}
