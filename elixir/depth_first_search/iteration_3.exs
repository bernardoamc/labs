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
# Difference between this code and the other one with processes:
#   - Now the DepthSearch module spawns itself and it also call functions
#     from the Graph module. This seems like a better approach since we
#     are not coupling the module so much anymoe.
#
# Question:
#   - Is this code acceptable? Seems like I'm overcomplicating things.
#
# Problems/Next steps:
#   - Is it ok to spawn a process for each node that is not a leaf? This
#     idea seems problematic since we can probably compute a node faster
#     than spawning a process. On the other hand it seems really awesome
#     to process each branch in a separate process. :p
#
#   - Suppose a path was found in some branch, but there is another REALLY
#     long branch that keeps a process alive. If we send an exit signal to
#     it, it will be queued or the processing will pause to deal with the signal
#     as happens in the C world? Also, should we use an `exit` or an `unlink` call
#     in this case?
#
#   - Talking with Hugo an idea of having a Supervisor emerged. Is this a good idea
#     to manage these kind of algorithms?
#
# Returns paths from child nodes of the source node as a List of nodes.
# If a path is not found an empty List is returned.
defmodule DepthSearch do
  def search(adjacency_matrix, source_index, end_index) do
    Graph.search_child_nodes(adjacency_matrix, source_index)
    |> Enum.map(fn(child_node) ->
      pid = spawn_link(__MODULE__, :run, [])
      send pid, {self, {adjacency_matrix, end_index, [child_node], [source_index]}}
    end)
    |> Enum.each(fn(_) ->
      receive do {:ok, solution} -> IO.inspect solution end
    end)
  end

  def run do
    receive do
      {sender, {adjacency_matrix, end_index, node_stack, visited}} ->
        send sender, {:ok, search_path(adjacency_matrix, end_index, node_stack, visited)}
        run
    end
  end

  # Path found
  defp search_path(_, end_index, [end_index|_], visited), do: visited ++ [end_index]

  # Path not found
  defp search_path(_, _, [], _), do: []

  defp search_path(adjacency_matrix, end_index, [current_node|nodes], visited_nodes) do
    child_nodes = Graph.search_child_nodes(adjacency_matrix, current_node)
    node_stack = child_nodes ++ nodes
    new_visited_nodes = visited_nodes ++ [current_node]

    search_path(adjacency_matrix, end_index, node_stack, new_visited_nodes)
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
