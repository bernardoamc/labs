/*
 *  Kruskal's algorithm gives us a Minimum Spanning Tree (MST).
 *  A minimum weight connected graph with no cycles.
 *
 *  How it works: https://www.youtube.com/watch?v=71UQH7Pr9kU
 *
 *  How do we see if a picked edge generates a cycle?
 *  - Checking if the vertices are part of the same disjointed set.
 *    The technique we are going to use is the Union-Find algorithm.
 *
 *  Learn about disjointed sets: https://www.youtube.com/watch?v=_cuhmxi14mc
 *
 *  How do we sort the edges?
 *  - We can use merge sort or quick sort.
 *
 *  How is Kruskal different than Prim's algorithm?
 *  - When you have way more edges than vertices it's best to use
 *    Prim's algorithm, but when you have a sparse graph (few edges)
 *    its best to use Kruskal since it uses simpler data structures.
 *  - Another interesting property is that Kruskal's algorithm don't
 *    require the graph to be connected.
 *
 *  The input is the following:
 *  nodes edges
 *  node node weight  }
 *  ...               | Each line is an edge, this section has <edges> lines.
 *  node node weight  }
 *
 *  The output represents the total weight of the generated graph.
 *
 *  Example of input:
 *
 *   4 6
 *   1 2 5
 *   1 3 3
 *   4 1 6
 *   2 4 7
 *   3 2 4
 *   3 4 5
 *
 *   Output: 12
 *
*/

#include <stdio.h>
#include <stdlib.h>

typedef struct edge {
  int from;
  int to;
  int weight;
} Edge;

int findLeaderSet (int *disjoint_sets, int vertice);
void unionSet(int *disjoint_sets, int vertice1, int leader1, int vertice2, int leader2);
int compare(const void *edge1, const void *edge2);

int main(int argc, char *argv[]) {
  int nodes, edges_count, from, to, total_weight;

  scanf("%d %d", &nodes, &edges_count);

  Edge *edges = malloc(edges_count * sizeof(Edge));
  int *disjoint_sets = malloc(nodes * sizeof(int));

  for (int i = 0; i < nodes; i++) {
    disjoint_sets[i] = i;
  }

  for (int i = 0; i < edges_count; i++) {
    scanf("%d %d %d", &from, &to, &total_weight);

    edges[i].from = --from;
    edges[i].to = --to;
    edges[i].weight = total_weight;
  }

  qsort (edges, edges_count, sizeof(Edge), compare);

  total_weight = 0;

  for (int i = 0; i < edges_count; i++) {
    int leader1 = findLeaderSet(disjoint_sets, edges[i].from);
    int leader2 = findLeaderSet(disjoint_sets, edges[i].to);

    // Both vertices are from the same set.
    if (leader1 == leader2) continue;

    unionSet(disjoint_sets, edges[i].from, leader1, edges[i].to, leader2);
    total_weight += edges[i].weight;
  }

  printf("%d\n", total_weight);

  return 0;
}

int findLeaderSet (int *disjoint_sets, int vertice) {
  if (vertice == disjoint_sets[vertice]) {
    return vertice;
  }

  return findLeaderSet(disjoint_sets, disjoint_sets[vertice]);
}

void unionSet(int *disjoint_sets, int vertice1, int leader1, int vertice2, int leader2) {
  int new_leader = (leader1 > leader2) ? leader1 : leader2;

  while (disjoint_sets[vertice1] != leader1) {
    vertice1 = disjoint_sets[vertice1];
    disjoint_sets[vertice1] = leader1;
  }

  while (disjoint_sets[vertice2] != leader2) {
    vertice2 = disjoint_sets[vertice2];
    disjoint_sets[vertice2] = leader2;
  }

  disjoint_sets[leader1] = new_leader;
  disjoint_sets[leader2] = new_leader;
}

int compare(const void *edge1, const void *edge2) {
    Edge a = *((Edge *)edge1);
    Edge b = *((Edge *)edge2);

    return (a.weight > b.weight) - (a.weight < b.weight);
}
