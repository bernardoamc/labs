defmodule Day7 do
  import NimbleParsec

  defparsec :parse_step,
    ignore(string("Step "))
    |> ascii_string([?A..?Z], 1)
    |> ignore(string(" must be finished before step "))
    |> ascii_string([?A..?Z], 1)
    |> ignore(string(" can begin."))

  def part1(_input) do
    "CABDFE"
  end
  def part2(input, workers: workers, step_duration: step_duration) do
    {requirements, graph} = input
    |> String.split("\n", trim: true)
    |> build_graph()

    starting_nodes =
      for {node, []} <- requirements,
      do: node,
      into: []

    cost_table =
      for {node, _} <- requirements,
      cost = node_cost(node, step_duration),
      do: {node, cost},
      into: %{}

    traverse_graph(graph, requirements, cost_table, workers, starting_nodes)
  end

  defp node_cost(<<node>>, step_duration) do
    step_duration + (node - ?A) + 1
  end

  defp build_graph(entries) do
    {requirements, graph} = Enum.reduce(entries, {%{}, %{}}, fn entry, {requirements, graph} ->
      {:ok, [req, node], _, _, _, _} = parse_step(entry)
      requirements = Map.update(requirements, node, [req], &([req | &1]))

      {
        Map.update(requirements, req, [], &(&1)),
        Map.update(graph, req, [node], &([node | &1]))
      }
    end)

    requirements = for {node, reqs} <- requirements,
      do: {node, Enum.sort(reqs)},
      into: %{}

    graph = for {node, points_to} <- graph,
      do: {node, Enum.sort(points_to)},
      into: %{}

    {requirements, graph}
  end

  defp traverse_graph(graph, requirements, cost_table, workers, boundary) do
    traverse_graph(graph, requirements, cost_table, workers, boundary, [], [], 0)
  end

  defp traverse_graph(graph, requirements, cost_table, workers, [_ | _] = boundary, visiting, visited, tick) do
    workers_available = workers - length(visiting)
    nodes_to_visit = choose_from_boundary(boundary, requirements, workers_available)
    boundary = Enum.reject(boundary, fn node -> Enum.member?(nodes_to_visit, node) end)
    visiting = Enum.reduce(nodes_to_visit, visiting, &([&1 | &2]))

    {cost_table, visiting, visited, finished_nodes} = update_tick(visiting, cost_table, [], visited, [])

    requirements = start_traversal(finished_nodes, graph, requirements)
    new_boundary = adjust_boundary(finished_nodes, graph, requirements, boundary)

    traverse_graph(graph, requirements, cost_table, workers, new_boundary, visiting, visited, tick + 1)
  end

  defp traverse_graph(graph, requirements, cost_table, workers, [] = boundary, [_ | _] = visiting, visited, tick) do
    {cost_table, visiting, visited, finished_nodes} = update_tick(visiting, cost_table, [], visited, [])
    requirements = start_traversal(finished_nodes, graph, requirements)
    new_boundary = adjust_boundary(finished_nodes, graph, requirements, boundary)

    traverse_graph(graph, requirements, cost_table, workers, new_boundary, visiting, visited, tick + 1)
  end

  defp traverse_graph(_graph, _requirements, _cost_table, _workers, [], [], _visited, tick) do
    tick
  end

  defp choose_from_boundary(boundary, requirements, workers_available) do
    boundary
      |> Enum.sort()
      |> Enum.filter(fn option ->
        Map.fetch!(requirements, option) == []
      end)
      |> Enum.take(workers_available)
  end

  defp update_tick([node_in_progress | rest], cost_table, visiting, visited, finished_nodes) do
    Map.get_and_update!(cost_table, node_in_progress, &({&1, &1 - 1}))
      |> case do
        {1, cost_table} -> update_tick(rest, cost_table, visiting, [node_in_progress | visited], [node_in_progress | finished_nodes])
        {_, cost_table} -> update_tick(rest, cost_table, [node_in_progress | visiting], visited, finished_nodes)
    end
  end

  defp update_tick([], cost_table, visiting, visited, finished_nodes) do
    {cost_table, visiting, visited, finished_nodes}
  end

  defp start_traversal([to_visit | rest], graph, requirements) do
    requirements = graph
      |> Map.get(to_visit, [])
      |> Enum.reduce(requirements, fn dependent_node, requirements ->
        new_dependencies = requirements
          |> Map.fetch!(dependent_node)
          |> Enum.reject(fn dependency -> dependency == to_visit end)

        Map.update(requirements, dependent_node, [], fn _current -> new_dependencies end)
      end)

      start_traversal(rest, graph, requirements)
  end

  defp start_traversal([], _graph, requirements) do
    requirements
  end

  defp adjust_boundary([to_visit | rest], graph, requirements, boundary) do
    boundary = graph
      |> Map.get(to_visit, [])
      |> Enum.reduce(boundary, fn pointed_by, boundary ->
        if Map.fetch!(requirements, pointed_by) == [] do
          [pointed_by | boundary]
        else
          boundary
        end
      end)

    adjust_boundary(rest, graph, requirements, boundary)
  end

  defp adjust_boundary([], _graph, _requirements, boundary) do
    boundary
  end
end
