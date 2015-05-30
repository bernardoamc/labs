# Graph exploration using the Depth-first search.
#
# The idea here is to start at the source node (or root) and exploring as far
# as possible along each branch before backtracking.
#
# Question:
#   - Can this code be improved?
#
# Returns the first path found as a List of nodes.
defmodule DepthSearch do
  def search(adjacency_matrix, source_index, end_index) do
    search(adjacency_matrix, end_index, [source_index], [])
  end

  # Path found
  defp search(_, end_index, [end_index|_], list), do: list ++ [end_index]

  # Path not found
  defp search(_, _, [], _), do: []

  defp search(adjacency_matrix, end_index, [current_node|nodes], visited_nodes)  do
    child_nodes = Enum.at(adjacency_matrix, current_node)
      |> Enum.with_index
      |> Enum.reduce([], &add_node/2)

    node_stack = child_nodes ++ nodes
    new_visited_nodes = visited_nodes ++ [current_node]

    search(adjacency_matrix, end_index, node_stack, new_visited_nodes)
  end

  defp add_node({path, node}, paths) when path == 1, do: paths ++ [node]
  defp add_node(_, paths), do: paths
end

adjacency_matrix = [
#  A  B  C  D  E  F  G
  [0, 1, 1, 0, 0, 0, 0], # A
  [0, 0, 0, 1, 1, 0, 0], # B
  [0, 0, 0, 0, 0, 1, 1], # C
  [0, 0, 0, 0, 0, 0, 0], # D
  [0, 0, 0, 0, 0, 0, 0], # E
  [0, 0, 0, 0, 0, 0, 0], # F
  [0, 0, 0, 0, 0, 0, 0]  # G
]

IO.inspect DepthSearch.search(adjacency_matrix, 0, 5)
