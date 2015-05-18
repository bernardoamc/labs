#ifndef _LINKED_LIST
#define _LINKED_LIST

typedef struct list {
  int value;
  struct list *next;
} list;

list * create_node(int value);
void print_list(list *l);
list * search_list(list *l, int value);
void insert_list(list **l, int value);
list * predecessor_list(list *l, int value);
void delete_list(list **l, int value);
#endif
