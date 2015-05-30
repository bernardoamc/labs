# Graph exploration using the Depth-first search.
#
# The idea here is to start at the source node (or root) and exploring as far
# as possible along each branch before backtracking.
#
# Idea behind this code:
#   - Spawn a process for each child of the source node. With this we
#     are able to find at least one path from each main branch to our
#     goal (if it exists).
#
# Question:
#   - The Graph module spawns a function from the DepthSearch module
#     and the DepthSearch module calls a functions from the Graph module,
#     this means they are tightly coupled, is this a problem?
#
# Returns paths from child nodes of the source node as a List of nodes.
# If a path is not found an empty List is returned.
defmodule DepthSearch do
  def search do
    receive do
      {sender, {adjacency_matrix, end_index, node_stack, visited}} ->
        send sender, {:ok, search(adjacency_matrix, end_index, node_stack, visited)}
        search
    end
  end

  # Path found
  defp search(_, end_index, [end_index|_], visited), do: visited ++ [end_index]

  # Path not found
  defp search(_, _, [], _), do: []

  defp search(adjacency_matrix, end_index, [current_node|nodes], visited_nodes) do
    child_nodes = Graph.search_child_nodes(adjacency_matrix, current_node)
    node_stack = child_nodes ++ nodes
    new_visited_nodes = visited_nodes ++ [current_node]

    search(adjacency_matrix, end_index, node_stack, new_visited_nodes)
  end
end

defmodule Graph do
  def dfs_search(adjacency_matrix, source_index, end_index) do
    search_child_nodes(adjacency_matrix, source_index)
    |> Enum.map(fn(child_node) ->
      pid = spawn_link(DepthSearch, :search, [])
      send pid, {self, {adjacency_matrix, end_index, [child_node], [source_index]}}
    end)
    |> Enum.each(fn(_) ->
      receive do {:ok, solution} -> IO.inspect solution end
    end)
  end

  def search_child_nodes(adjacency_matrix, node) do
    Enum.at(adjacency_matrix, node)
      |> Enum.with_index
      |> Enum.reduce([], &add_node/2)
  end

  defp add_node({path, node}, paths) when path == 1, do: paths ++ [node]
  defp add_node(_, paths), do: paths
end

adjacency_matrix = [
#  A  B  C  D  E  F  G
  [0, 1, 1, 0, 0, 0, 0], #A
  [0, 0, 0, 1, 1, 0, 0], #B
  [0, 0, 0, 0, 0, 1, 1], #C
  [0, 0, 0, 0, 0, 0, 0], #D
  [0, 0, 0, 0, 0, 0, 0], #E
  [0, 0, 0, 0, 0, 0, 0], #F
  [0, 0, 0, 0, 0, 0, 0]  #G
]

Graph.dfs_search(adjacency_matrix, 0, 5)
