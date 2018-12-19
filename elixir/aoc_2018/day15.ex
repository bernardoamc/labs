# Starting to try implementation with A* over BFS
defmodule Day15 do
  def part1(input, _attack_powers) do
    {grid, units} =
      input
      |> String.split("\n", strip: true)
      |> parse_board_state(0, %{}, %{})


      Graph.astar(grid, units, {2,1}, {4,2})
  end

  defp parse_board_state([row | rows], y, grid, units) do
    {grid, units, _} =
      row
      |> to_charlist()
      |> parse_row(grid, units, y)

    parse_board_state(rows, y+1, grid, units)
  end

  defp parse_board_state([], _, grid, units) do
    {grid, units}
  end

  defp parse_row(row, grid, units, y) do
    Enum.reduce(row, {grid, units, 0}, fn char, {grid, units, x} ->
      unit = parse_unit(char)

      if is_nil(unit) do
        grid = Map.put_new(grid, {x,y}, parse_element(char))
        {grid, units, x+1}
      else
        grid = Map.put_new(grid, {x,y}, :open)
        units = Map.put_new(units, {x,y}, unit)
        {grid, units, x+1}
      end
    end)
  end

  defp parse_element(?#), do: :wall
  defp parse_element(?.), do: :open

  defp parse_unit(?E), do: :elf
  defp parse_unit(?G), do: :goblin
  defp parse_unit(_), do: nil
end

defmodule Graph do
  def astar(grid, units, start, goal) do
    data = %{
      grid: grid,
      units: units,
      frontier: [{0, start}] |> Enum.into(PriorityQueue.new),
      came_from: %{start => nil},
      cost_so_far: %{start => 0},
      goal: goal
    }

    search(data)
  end

  defp search(data) do
    {{_cost, current}, frontier} = PriorityQueue.pop(data.frontier)

    if current == data.goal do
      {data.came_from, data.cost_so_far}
    else
      {cost_so_far, frontier, came_from} = search_neighbours(current, %{data | frontier: frontier})
      search(%{data | cost_so_far: cost_so_far, frontier: frontier, came_from: came_from})
    end
  end

  defp search_neighbours(current, data) do
    neighbours = find_neighbours(current, data.grid, data.units, data.goal)
    current_state = {data.cost_so_far, data.frontier, data.came_from}

    Enum.reduce(neighbours, current_state, fn neighbour, {cost_so_far, frontier, came_from} ->
      new_cost = Map.fetch!(cost_so_far, current) + 1

      if qualify?(current, neighbour, cost_so_far) do
        cost_so_far = Map.put(cost_so_far, neighbour, new_cost)
        heuristic = new_cost + heuristic_cost(data.goal, neighbour)
        frontier = PriorityQueue.put(frontier, {new_cost + heuristic, neighbour})
        came_from = Map.put(came_from, neighbour, current)

        {cost_so_far, frontier, came_from}
      else
        {cost_so_far, frontier, came_from}
      end
    end)
  end

  defp qualify?(current, neighbour, cost_so_far) do
    new_cost = Map.fetch!(cost_so_far, current) + 1

    !Map.has_key?(cost_so_far, neighbour) or
    Map.get(cost_so_far, neighbour) < new_cost
  end

  defp find_neighbours({x,y}, grid, units, goal) do
    possible_moves = [{x-1, y}, {x+1, y}, {x, y-1}, {x, y+1}]

    Enum.filter(possible_moves, fn location ->
      (Map.get(grid, location, :wall) == :open && !Map.has_key?(units, location)) or
      location == goal
    end)
  end

  defp heuristic_cost({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end
end
