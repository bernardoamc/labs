/*
 * Goal: Find the minimum size of the largest clique in any graph with N nodes
 *       and M edges.
 *
 * The idea here is that Turan's Theorem gives us the maximum number of edges
 * a graph must have such that there isn't a (K+1) clique.
 *
 * Suppose the formula gives us: 18 and we have 16 edges, it is guaranteed
 * that we don't have a clique with size (K+1) in this case.
 *
 * What we need to do here is find a size K such that the formula returns
 * a number less than the number of edges and a formula with K+1 that gives
 * us a size greater or equal the number of edges. This way we know that the
 * maximum clique size is K+1;
 *
 * To achieve this goal faster we use a binary search to speed things up.
 *
 * Constraints
 * 1 <= T <= 100000
 * 2 <= N <= 10000
 * 1 <= M <= N*(N-1)/2
 *
 * Sample Input
 * 3          -> Test Cases to follow
 * 3 2        -> Nodes Edges
 * 4 6        -> Nodes Edges
 * 5 7        -> Nodes Edges
 *
 * Sample Output
 * 2
 * 4
 * 3
*/

#include <stdio.h>
#include <math.h>

int formula(unsigned int vertices, unsigned int k) {
  int squared = vertices * vertices;
  int clique_mod = vertices % k;
  int upper = ceil((double)vertices/(double)k);
  int lower = floor((double)vertices/(double)k);

  return (squared - (clique_mod * upper * upper) - (k - clique_mod)* lower * lower) / 2;
}

int main() {
  unsigned int cases, vertices, edges;
  int k;

  scanf("%u", &cases);

  while(cases--) {
    scanf("%u %u", &vertices, &edges);

    int min = 1;
    int max = vertices;
    k = (min + max)/2;

    while(k <= vertices && k >= 1) {
      int f = formula(vertices, k);
      int f_plus_1 = formula(vertices, k + 1);

      if (edges > f) {
        if (edges <= f_plus_1) {
         printf("%d\n", k+1);
         break;
        }

        min = k + 1;
      } else {
        max = k - 1;
      }

      k = (min + max)/2;
    }
  }

  return 0;
}

