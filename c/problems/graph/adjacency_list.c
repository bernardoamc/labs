/*
 * An adjacency list is a form used to represent a graph. It uses a list
 * of linked lists to keep track of edges. Let's see an example:
 *
 * Our vertices: 0, 1, 2, 3
 * Our edges: [0,1], [1,2], [3,1], [3,2]
 * Internal representation:
 *
 * [0] -> [1] -> NULL
 * [1] -> [2] -> NULL
 * [2] -> NULL
 * [3] -> [1] -> [2] -> NULL
 *
*/

#include <stdio.h>
#include <stdlib.h>

typedef struct node
{
  int edge;
  int value;
  struct node* next;
} Node;

typedef struct list {
  Node *head;
} List;

List* initGraph(int nodes);
Node* searchEdge(Node *head, int edge, Node **prev);
void insertEdge(List *list, int edge, int value);
void removeEdge(List *list, int edge);
void printList(List *list);

int main(int argc, char *argv[]) {
  List *graph = initGraph(5);

  insertEdge(&graph[0], 3, 5);
  insertEdge(&graph[0], 4, 10);
  insertEdge(&graph[1], 2, 3);
  insertEdge(&graph[1], 4, 5);
  insertEdge(&graph[2], 1, 3);
  insertEdge(&graph[2], 3, 7);
  insertEdge(&graph[3], 0, 15);
  insertEdge(&graph[3], 1, 35);
  insertEdge(&graph[3], 2, 1);
  insertEdge(&graph[3], 4, 17);
  insertEdge(&graph[4], 2, 100);

  for(int i = 0; i < 5; i++) {
    printList(&graph[i]);
    printf("\n");
  }

  printf("\n\n");

  removeEdge(&graph[0], 4);

  removeEdge(&graph[2], 3);

  removeEdge(&graph[3], 0);
  removeEdge(&graph[3], 1);
  removeEdge(&graph[3], 2);
  removeEdge(&graph[3], 4);

  for(int i = 0; i < 5; i++) {
    printList(&graph[i]);
    printf("\n");
  }

  return 0;
}

List* initGraph(int nodes) {
  List *lists = malloc(nodes * sizeof(List));

  for (int i = 0; i < nodes; i++) {
    lists[i].head = NULL;
  }

  return lists;
}

void insertEdge(List *list, int edge, int value) {
  Node *node = malloc(sizeof(Node));

  node->edge = edge;
  node->value = value;
  node->next = list->head;
  list->head = node;
}

Node* searchEdge(Node *head, int edge, Node **prev) {
  Node *ptr = head;
  Node *tmp = NULL;
  int found = 0;

  while(ptr != NULL) {
    if(ptr->edge == edge) {
      found = 1;
      break;
    }

    tmp = ptr;
    ptr = ptr->next;
  }

  if(found) {
    *prev = tmp;
    return ptr;
  }

  return NULL;
}

void removeEdge(List *list, int edge) {
  Node *prev = NULL;
  Node *del = NULL;

  del = searchEdge(list->head, edge, &prev);

  if (del != NULL) {
    if(del == list->head) {
      list->head = del->next;
    } else if(prev != NULL) {
      prev->next = del->next;
    }

    free(del);
  }
}

void printList(List *list) {
  Node *ptr = list->head;

  while(ptr != NULL)
  {
      printf("[%d|%d]",ptr->edge, ptr->value);
      ptr = ptr->next;
  }
}
