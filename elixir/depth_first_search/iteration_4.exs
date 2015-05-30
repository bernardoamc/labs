# Graph exploration using the Depth-first search.
#
# The idea here is to start at the source node (or root) and exploring as far
# as possible along each branch before backtracking.
#
# Improvements:
#   - Send the arguments to run using spawn_link third argument instead
#     of passing it by send. We don't need to be flexible with messages,
#     we just want to spawn the new process and make it run.
#
#   - Appending elements to a list with the `++` operator is inefficient
#     since we have to copy the entire list. To fix this we can prepend
#     each element and at the end of the function do a `List.reverse`.
#
#   - Rename some variables.
#
# Returns paths from child nodes of the source node as a List of nodes.
# If a path is not found an empty List is returned.
defmodule DepthSearch do
  def search(adjacency_matrix, root, goal) do
    Graph.search_child_nodes(adjacency_matrix, root)
    |> Enum.map(fn(child_node) ->
      spawn_link(__MODULE__, :run, [adjacency_matrix, goal, [child_node], [root], self])
    end)
    |> Enum.each(fn(_) ->
      receive do {:ok, solution} -> IO.inspect solution end
    end)
  end

  def run(adjacency_matrix, goal, node_stack, visited, sender) do
    send sender, {:ok, search_path(adjacency_matrix, goal, node_stack, visited)}
  end

  # Path found
  defp search_path(_, goal, [goal|_], visited), do: Enum.reverse([goal|visited])

  # Path not found
  defp search_path(_, _, [], _), do: []

  defp search_path(adjacency_matrix, goal, [current_node|nodes], visited_nodes) do
    child_nodes = Graph.search_child_nodes(adjacency_matrix, current_node)
    node_stack = child_nodes ++ nodes # Is there a way to prepend here?
    new_visited_nodes = [current_node|visited_nodes]

    search_path(adjacency_matrix, goal, node_stack, new_visited_nodes)
  end
end

defmodule Graph do
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

DepthSearch.search(adjacency_matrix, 0, 5)
