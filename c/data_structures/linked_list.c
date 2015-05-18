#include <stdio.h>
#include <stdlib.h>
#include "linked_list.h"

int main(int argc, char *argv[])
{
  list *root = create_node(0);

  insert_list(&root, 5);
  insert_list(&root, 4);
  insert_list(&root, 3);
  insert_list(&root, 2);
  insert_list(&root, 1);

  delete_list(&root, 1);

  if (search_list(root, 3) != NULL) {
    printf("The value 3 exists in the list.\n");
  }

  delete_list(&root, 3);

  if (search_list(root, 3) == NULL) {
    printf("Now the value 3 does not exist anymore.\n");
  }

  printf("The remaining values in the list are:");
  print_list(root);
  printf("\n");

  exit(EXIT_SUCCESS);
}

list * create_node(int value) {
  list *node = NULL;

  node = malloc(sizeof(list));

  if (node == NULL) {
    printf("Out of memory to insert a new value\n");
    exit(EXIT_FAILURE);
  }

  node->value = value;
  node->next = NULL;

  return node;
}

void print_list(list *l)
{
  printf(" %d", l->value);

  if (l->next != NULL) {
    print_list(l->next);
  }
}

list * search_list(list *l, int value)
{
  if (l == NULL) {
    return NULL;
  }

  if (l->value == value) {
    return l;
  }

  return search_list(l->next, value);
}

void insert_list(list **l, int value)
{
  list *temp;

  temp = malloc(sizeof(list));

  if (temp == NULL) {
    printf("Out of memory to insert a new value\n");
    exit(EXIT_FAILURE);
  }

  temp->value = value;
  temp->next = *l;

  *l = temp;
}

list * predecessor_list(list *l, int value)
{
  if ((l == NULL) || (l->next == NULL)) {
    return NULL;
  }

  if ((l->next)->value == value) {
    return l;
  }

  return predecessor_list(l->next, value);
}

void delete_list(list **l, int value)
{
  list *node;
  list *pred;

  node = search_list(*l, value);

  if (node != NULL) {
    pred = predecessor_list(*l, value);

    if (pred == NULL) {
      *l = node->next;
    } else {
      pred->next = node->next;
    }

    free(node);
  }
}
