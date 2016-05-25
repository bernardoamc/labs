/*
 * You are given a tree (a simple connected graph with no cycles). You have to
 * remove as many edges from the tree as possible to obtain a forest with the
 * condition that: Each connected component of the forest should contain an even
 * number of vertices.
 *
 * A forest is basically a tree, so you have to remove edges and generate new
 * trees with an even number of vertices.
 *
 * Input Format
 * The first line of input contains two integers N and M. N is the number of vertices and M is the number of edges.
 * The next M lines contain two integers ui and vi which specifies an edge of the tree. (1-based index)
 *
 * Output Format
 * Print the answer, a single integer.
 *
 * Constraints
 * 2 <= N <= 100.
 *
 * Sample Input
 *
 *  10 9
 *  2 1
 *  3 1
 *  4 3
 *  5 2
 *  6 1
 *  7 2
 *  8 6
 *  9 8
 *  10 8
 *
 *  Sample Output: 2
*/

#include <stdio.h>
#include <stdlib.h>

int main() {
  int nodes, edges, from, to;
  int splits = 0;

  scanf("%d %d", &nodes, &edges);

  int *parent_of = calloc(nodes, sizeof(int));
  int *child_count = calloc(nodes, sizeof(int));

  for(int i = 0; i < edges; i++) {
    scanf("%d %d", &to, &from);
    from--;
    to--;

    child_count[from]++;
    parent_of[to] = from;
  }

  // Counting all children instead of just the direct ones.
  for(int i = nodes - 1; i >= 0; i--) {
    for(int j = 0; j < nodes; j++) {
      if (parent_of[j] == i) {
        child_count[i] += child_count[j];
      }
    }
  }

  // If the node has an odd number of children we can cut it to
  // make a new even tree.
  for(int i = 1; i < nodes; i++) {
    if (child_count[i] && ((child_count[i] + 1) % 2 == 0)) {
      splits++;
    }
  }

  printf("%d\n", splits);

  return 0;
}

