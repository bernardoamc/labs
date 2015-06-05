# Graph exploration using the Depth-first search.
#
# The idea here is to start at the source node (or root) and exploring as far
# as possible along each branch before backtracking.
#
# Improvements:
#   - Create a server to deal with our search requests. Each request will
#     start a Supervisor, which in turn will start its workers. The first
#     worker that finish its job will send a message to our server containing
#     its associated Supervisor and the solution. With this our server can print
#     the solution and kill the Supervisor, which in turn will terminate the
#     remaining workers.
#
#     To kill our Supervisor we have to to unlink it first, otherwise our own
#     server will also terminate.
#
# Returns a paths from root node to the goal node as a List of nodes.
defmodule Search.Server do
  use GenServer

  def start_link(matrix) do
    GenServer.start_link(__MODULE__, matrix, name: __MODULE__)
  end

  def depth_search(root, goal) do
    GenServer.call(__MODULE__, {:depth_search, root, goal})
  end

  def handle_call({:depth_search, root, goal}, _from, matrix) do
    {:ok, _} = DepthSearch.Supervisor.start_link(matrix, root, goal, self)

    { :reply, :init_processing, matrix }
  end

  def handle_info({:ok, [_, []]}, _), do: nil

  def handle_info({:ok, [supervisor, solution]}, _) do
    IO.inspect solution
    Process.unlink(supervisor)
    Process.exit(supervisor, :shutdown)
  end
end

defmodule DepthSearch.Supervisor do
  use Supervisor

  def start_link(adjacency_matrix, root, goal, server) do
    result = {:ok, supervisor} = Supervisor.start_link(__MODULE__, nil)
    childs = start_workers(supervisor, adjacency_matrix, root, goal, server)
    start_processing(childs)

    result
  end

  def start_workers(supervisor, matrix, root, goal, server) do
    Graph.search_child_nodes(matrix, root)
    |> Enum.map(fn(child_node) ->
      {:ok, pid } = Supervisor.start_child(
        supervisor,
        worker(DepthSearch.Algorithm, [matrix, goal, [child_node], [root], supervisor, server], id: String.to_atom("node_#{child_node}"))
      )

      pid
    end)
  end

  def start_processing(childs) do
    Enum.each(childs, fn(child) -> GenServer.cast(child, :search) end)
  end

  def init(_) do
    supervise([], strategy: :one_for_one)
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

defmodule DepthSearch.Algorithm do
  use GenServer

  def start_link(matrix, goal, node_stack, visited, supervisor, server) do
    GenServer.start_link(__MODULE__, { matrix, goal, node_stack, visited, supervisor, server })
  end

  def handle_cast(:search, { matrix, goal, node_stack, visited, supervisor, server }) do
    send server, {:ok, [supervisor, search(matrix, goal, node_stack, visited)]}
  end

  # Path found
  defp search(_, goal, [goal|_], visited), do: Enum.reverse([goal|visited])

  # Path not found
  defp search(_, _, [], _), do: []

  defp search(matrix, goal, [current_node|nodes], visited_nodes) do
    child_nodes = Graph.search_child_nodes(matrix, current_node)
    node_stack = child_nodes ++ nodes
    new_visited_nodes = [current_node|visited_nodes]

    search(matrix, goal, node_stack, new_visited_nodes)
  end
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

{ :ok, _ } = Search.Server.start_link(adjacency_matrix)
IO.inspect Search.Server.depth_search(0, 5)
:timer.sleep 2000
