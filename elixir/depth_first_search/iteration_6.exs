# Graph exploration using the Depth-first search.
#
# The idea here is to start at the source node (or root) and exploring as far
# as possible along each branch before backtracking.
#
# Improvements:
#   - The goal of this algorithm is to discover a possible path from the
#     root node to the goal node, we don't need the shortest path. Knowing
#     this we can get the first available path and terminate the remaining
#     processes. There is no necessity to wait for all of them to finish as
#     we are doing with `Task.async` and `Task.await` combo.
#
#     The answers are [0, 1, 3, 4, 5] or [0, 2, 5], we don't care which one
#     we will receive since both are correct.
#
#     The current solution assumes that at least one path exists, if that's
#     not the case we should probably check our processes with `Process.info(pid)`
#     and end our program if there is no one alive anymore.
#
# Returns a paths from root node to the goal node as a List of nodes.
defmodule DepthSearch do
  def search(adjacency_matrix, root, goal) do
    pids = Graph.search_child_nodes(adjacency_matrix, root)
    |> Enum.map(fn(child_node) ->
      spawn_link(__MODULE__, :run, [adjacency_matrix, goal, [child_node], [root], self])
    end)

    fetch_answer(pids)
  end

  def fetch_answer(pids) do
    receive do
      {:ok, []} ->
        fetch_answer(pids)
      {:ok, solution} ->
        IO.inspect solution
        Enum.each(pids, fn(pid) -> Process.exit(pid, :solution_found) end)
    end
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
  [0, 1, 1, 1, 0, 0, 0], #A
  [0, 0, 0, 1, 1, 0, 0], #B
  [0, 0, 0, 0, 0, 1, 1], #C
  [0, 0, 0, 0, 1, 0, 0], #D
  [0, 0, 0, 0, 0, 1, 1], #E
  [0, 0, 0, 0, 0, 0, 0], #F
  [0, 0, 0, 0, 0, 0, 0]  #G
]

DepthSearch.search(adjacency_matrix, 0, 5)
