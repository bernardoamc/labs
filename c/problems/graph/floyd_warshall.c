/*
 *  Floyd-Warshall's algorithm gives us the shortest path between all vertices
 *  on the graphs and has O(n^3) complexity.
 *
 *  How it works: https://www.youtube.com/watch?v=KQ9zlKZ5Rzc
 *
 *  Alternative to Floyd-Warshall's algorithm:
 *  - Using Djikstra for all vertices on the graph.
 *
 *  The input is the following:
 *  nodes edges
 *  node node weight  }
 *  ...               | Each line is an edge, this section has <edges> lines.
 *  node node weight  }
 *  queries           } Number of questions asked
 *  node node         }
 *  ...               | We have to answer the shortest path from each node to node.
 *  node node         }
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
 *  Output:
 *
 *  5
 *  -1
 *  11
*/

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  int nodes, edges_count, from, to, weight, queries;

  scanf("%d %d", &nodes, &edges_count);

  int **matrix = malloc(nodes * sizeof(int *));

  for(int i = 0; i < nodes; i++) {
    matrix[i] = calloc(nodes, sizeof(int));
  }

  for (int i = 0; i < edges_count; i++) {
    scanf("%d %d %d", &from, &to, &weight);
    from--;
    to--;

    matrix[from][to] = weight;
  }

  for (int stop_by = 0; stop_by < nodes; stop_by++) {
    for (int row = 0; row < nodes; row++) {
      // Comparing the stop_by with itself will not change any values.
      if (stop_by == row) continue;

      for (int column= 0; column < nodes; column++) {
        // There is no path between these vertices.
        if (!matrix[row][stop_by] || !matrix[stop_by][column]) continue;

        int stop_cost = matrix[row][stop_by] + matrix[stop_by][column];

        // If it is a new path or the cost is less than the current path.
        if (!matrix[row][column] || (stop_cost < matrix[row][column])) {
          matrix[row][column] = stop_cost;
        }
      }
    }
  }

  scanf("%d", &queries);

  for (int i = 0; i < queries; i++) {
    scanf("%d %d", &from, &to);
    from--;
    to--;

    if (matrix[from][to]) {
      printf("%d\n", matrix[from][to]);
    }
    else {
      printf("-1\n");
    }
  }

  return 0;
}
