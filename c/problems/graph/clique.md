# Clique

To know what is a **clique** is, first we need to know what is a **complete
graph** (also known as **k-n** graph, where **n** is the number of vertices).

## Complete graph

A complete graph (k-n) is a graph where there are edges between all vertices of the graph. Let's see an example of a k-4 graph:

![K4 Graph](https://github.com/bernardoamc/labs/blob/master/c/problems/graph/images/k4_graph.bmp)

## So, what's a clique?

A clique of size n is basically a complete graph (k-n) that is a **subgraph** of a given graph.

### Propositions:

1.Given a graph with **2n** vertices and **n^2 + 1** edges, it always have a
triangle (k-3 graph) for **n > 2**.

2.The **maximum clique size (MC)** of a graph is always **bigger or equals** the **sum of (1 / n - di)**
where di is the degree of a vertice (number of edges it has). So we will
calculate **(1 / n - di)** for each vertice and sum the result. This result must
be coerced to integer using the *ceil* function.
