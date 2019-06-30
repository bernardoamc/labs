defmodule Part1 do
  import NimbleParsec

  defparsec :parse_step,
    ignore(string("Step "))
    |> ascii_string([?A..?Z], 1)
    |> ignore(string(" must be finished before step "))
    |> ascii_string([?A..?Z], 1)
    |> ignore(string(" can begin."))

  def part1(input) do
    {requirements, graph} = input
    |> String.split("\n", trim: true)
    |> build_graph()

    starting_nodes =
      for {node, []} <- requirements,
      do: node,
      into: []

    traverse_graph(graph, requirements, starting_nodes)
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

  defp traverse_graph(graph, requirements, boundary) do
    traverse_graph(graph, requirements, boundary, [])
  end

  defp traverse_graph(graph, requirements, [_ | _] = boundary, visited) do
    to_visit = choose_from_boundary(boundary, requirements)
    boundary = Enum.reject(boundary, fn node -> node == to_visit end)

    requirements =
      graph
      |> Map.get(to_visit, [])
      |> Enum.reduce(requirements, fn pointed_by, requirements ->
        new_dependencies = requirements
          |> Map.fetch!(pointed_by)
          |> Enum.reject(fn dependency -> dependency == to_visit end)

        Map.update(requirements, pointed_by, [], fn _current -> new_dependencies end)
      end)

      boundary =
        graph
        |> Map.get(to_visit, [])
        |> Enum.reduce(boundary, fn pointed_by, boundary ->
          if Map.fetch!(requirements, pointed_by) == [] do
            [pointed_by | boundary]
          else
            boundary
          end
        end)

      traverse_graph(graph, requirements, boundary, [to_visit | visited])
  end

  defp traverse_graph(_graph, _requirements, [], visited) do
    visited |> Enum.reverse() |> List.to_string()
  end

  defp choose_from_boundary(boundary, requirements) do
    boundary
      |> Enum.sort()
      |> Enum.find(fn option ->
        Map.fetch!(requirements, option) == []
      end)
  end
end
