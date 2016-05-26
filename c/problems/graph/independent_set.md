# Independent set

An independent set in a graph G = (V, E) is a subset A of V such that for any
pair of vertices ![(i,j)
](https://github.com/bernardoamc/labs/blob/master/c/problems/graph/images/pair_in.png),
they don't have an edge.

## Estimate the maximum size of an independent set in graph G

![Maximum size](https://github.com/bernardoamc/labs/blob/master/c/problems/graph/images/maximum_size_ind.png)

1. Being **d(i)** the degree (number of edges) of vertice **i**.
2. The result of ind(G) must be an integer, so the function **ceil** should be
used in the result.
