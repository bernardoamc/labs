# Clique

To know what is a **clique**, first we need to know what is a **complete
graph** (also known as **k-n** graph, where **n** is the number of vertices).

## Complete graph

A complete graph (k-n) is a graph where there are edges between all vertices of the graph. Let's see an example of a k-4 graph:

![K4 Graph](https://github.com/bernardoamc/labs/blob/master/c/problems/graph/images/k4_graph.bmp)

## So, what's a clique?

A clique of size **n** is basically a **complete graph (k-n)** that is a **subgraph** of a given graph.

### Proposition 1:

Given a graph with **2n** vertices and **n^2 + 1** edges, it always have a
triangle (k-3 graph) for **n > 2**.

### Proposition 2:

The **maximum clique size (MC)** of a graph is:

![Maximum clique size](https://github.com/bernardoamc/labs/blob/master/c/problems/graph/images/mc.png)

1. Being **d(i)** the degree (number of edges) of vertice **i**.
2. The result of ind(G) must be an integer, so the function **ceil** should be
used in the result.

### Proposition 3:

Given a graph with **n** vertices and **a** edges, the **maximum clique size is**:

![Maximum clique size](https://github.com/bernardoamc/labs/blob/master/c/problems/graph/images/mc2.png)

### Turan's Theorem

Let **G(V,E)** be a graph with graph vertices **V** and graph edges **E** on
**n** graph vertices without a (k+1)-clique. Then:

![Turan1](https://github.com/bernardoamc/labs/blob/master/c/problems/graph/images/turan1.gif)

where **t(n,k) is the edge count**.

The Turán graph **T(n,k)** is defined as the unique graph without a (k+1)-clique
having the maximum possible number of graph edges, namely

![Turan2](https://github.com/bernardoamc/labs/blob/master/c/problems/graph/images/turan2.gif)

where **|_x_|** denotes the floor function.
