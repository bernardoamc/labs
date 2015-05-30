# Graph exploration using the Depth-first search.
#
# The idea here is to start at the source node (or root) and exploring as far
# as possible along each branch before backtracking.
#
# Improvements:
#   - Use `Task.async` and `Task.await` instead of `spawn_link`. This makes
#     sense since Tasks are meant to execute one particular action without
#     communication with other processes (usually). As the documentation
#     says:
#
#       "The most common use case for tasks is to compute a value asynchronously."
#
#     Tasks can also be started as part of supervision trees.
#
# Returns paths from child nodes of the source node as a List of nodes.
# If a path is not found an empty List is returned.
defmodule DepthSearch do
  def search(adjacency_matrix, root, goal) do
    Graph.search_child_nodes(adjacency_matrix, root)
    |> Enum.map(fn(child_node) ->
      Task.async(__MODULE__, :search_path, [adjacency_matrix, goal, [child_node], [root]])
    end)
    |> Enum.each(fn(task) ->
      # This blocks the loop until an answer is returned. Can we avoid this?
      IO.inspect Task.await(task)
    end)
  end

  # Path found
  def search_path(_, goal, [goal|_], visited), do: Enum.reverse([goal|visited])

  # Path not found
  def search_path(_, _, [], _), do: []

  def search_path(adjacency_matrix, goal, [current_node|nodes], visited_nodes) do
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
