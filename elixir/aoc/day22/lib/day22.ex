defmodule Day22 do
  alias Day22.Graph

  def part1(depth, {x,y}) do
    build_cave(0..x, 0..y, x, y, depth)
      |> elem(0)
      |> cave_risk(0..x, 0..y)
  end

  def part2(depth, {x,y}) do
    range_x = 0..(x+100)
    range_y = 0..(y+100)

    build_cave(range_x, range_y, x, y, depth) |> elem(0)
      |> Graph.dijkstra({0,0}, {x, y})
      |> Map.fetch!({{x, y}, :torch})
  end

  defp build_cave(x_range, y_range, target_x, target_y, depth) do
    Enum.reduce(x_range, {%{}, %{}}, fn x, {cave, erosion_map} ->
      Enum.reduce(y_range, {cave, erosion_map}, fn y, {cave, erosion_map} ->
        geo_index = geologic_index(x, y, target_x, target_y, erosion_map)
        erosion = erosion_level(geo_index, depth)
        category = categorize(erosion)

        {Map.put_new(cave, {x,y}, category), Map.put_new(erosion_map, {x,y}, erosion)}
      end)
    end)
  end

  defp cave_risk(cave, x_range, y_range) do
    Enum.reduce(x_range, 0, fn x, risk ->
      Enum.reduce(y_range, risk, fn y, risk ->
        case Map.fetch!(cave, {x, y}) do
          :rocky -> risk
          :wet -> risk + 1
          :narrow -> risk + 2
        end
      end)
    end)
  end

  defp geologic_index(0, 0, _target_x, _target_y, _erosion_cache), do: 0
  defp geologic_index(x, 0, _target_x, _target_y, _erosion_cache), do: x * 16807
  defp geologic_index(0, y, _target_x, _target_y, _erosion_cache), do: y * 48271
  defp geologic_index(target_x, target_y, target_x, target_y, _erosion_cache), do: 0
  defp geologic_index(x, y, _target_x, _target_y, erosion_cache), do: Map.fetch!(erosion_cache, {x-1, y}) * Map.fetch!(erosion_cache, {x, y-1})

  defp erosion_level(geologic_index, depth), do: rem(geologic_index + depth, 20183)

  defp categorize(erosion_level) do
    case rem(erosion_level, 3) do
      0 -> :rocky
      1 -> :wet
      2 -> :narrow
    end
  end

  defmodule Graph do
    @tool_change_cost 7
    @move_cost 1

    def dijkstra(grid, start, goal) do
      graph = %{
        grid: grid,
        frontier: [{0, {start, :torch}}] |> Enum.into(PriorityQueue.new),
        came_from: %{start => {nil, nil}},
        cost_so_far: %{},
        goal: {goal, :torch}
      }

      search(graph)
    end

    defp search(graph) do
      {{cost, {current_location, current_tool}}, frontier} = PriorityQueue.pop(graph.frontier)
      location_key = {current_location, current_tool}

      # Since it's a priority queue we know that the cost given a {location, tool} is the lowest one.
      if !Map.has_key?(graph.cost_so_far, location_key) do
        updated_graph = %{graph | frontier: frontier, cost_so_far: Map.put(graph.cost_so_far, location_key, cost)}

        if {current_location, current_tool} == graph.goal do
          updated_graph.cost_so_far
        else
          {cost_so_far, frontier, came_from} = search_neighbours(updated_graph, current_location, current_tool)
          search(%{updated_graph | cost_so_far: cost_so_far, frontier: frontier, came_from: came_from})
        end
      else
        search(%{graph | frontier: frontier})
      end
    end

    defp search_neighbours(graph, current_location, current_tool) do
      possible_tools =
        graph.grid
        |> allowed_tools(current_location)
        |> Enum.reduce([], fn tool, tools ->
          if tool == current_tool, do: tools, else: [tool | tools]
        end)

      # We pushing the state of a tool change in the frontier
      new_frontier =
        Enum.reduce(possible_tools, graph.frontier, fn tool_change, frontier ->
          new_cost = Map.fetch!(graph.cost_so_far, {current_location, current_tool}) + @tool_change_cost
          PriorityQueue.put(frontier, {new_cost, {current_location, tool_change}})
        end)


      neighbours = find_neighbours(graph.grid, current_location, current_tool)
      current_state = {graph.cost_so_far, new_frontier, graph.came_from}

      Enum.reduce(neighbours, current_state, fn neighbour, {cost_so_far, frontier, came_from} ->
        new_cost = Map.fetch!(cost_so_far, {current_location, current_tool}) + @move_cost

        frontier = PriorityQueue.put(frontier, {new_cost, {neighbour, current_tool}})
        came_from = Map.put(came_from, neighbour, {current_location, current_tool})

        {cost_so_far, frontier, came_from}
      end)
    end

    defp find_neighbours(grid, {x,y}, current_tool) do
      [{x-1, y}, {x+1, y}, {x, y-1}, {x, y+1}]
        |> Enum.filter(fn next_location ->
          Map.has_key?(grid, next_location) && (current_tool in allowed_tools(grid, next_location))
        end)
    end

    defp allowed_tools(grid, position) do
      case Map.fetch!(grid, position) do
        :rocky -> [:climbing_gear, :torch]
        :wet -> [:climbing_gear, :neither]
        :narrow -> [:torch, :neither]
      end
    end
  end
end
