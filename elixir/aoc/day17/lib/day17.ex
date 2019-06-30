defmodule Day17 do
  import NimbleParsec

  #1 @ 1,3: 4x4
  defparsec :parse_y_range,
    ignore(string("x="))
    |> integer(min: 1)
    |> ignore(string(", y="))
    |> integer(min: 1)
    |> ignore(string(".."))
    |> integer(min: 1)

  defparsec :parse_x_range,
    ignore(string("y="))
    |> integer(min: 1)
    |> ignore(string(", x="))
    |> integer(min: 1)
    |> ignore(string(".."))
    |> integer(min: 1)

  def part1(input) do
    map =
      input
      |> String.split("\n", strip: true)
      |> Stream.reject(&(&1 == ""))
      |> Stream.map(&parse_clay/1)
      |> generate_clay_map()

    {{_, top}, {_, bottom}} = map |> Map.keys |> Enum.min_max_by(&(elem(&1, 1)))

    state = %{
      map: map,
      top: top,
      bottom: bottom + 1
    }

    {_, state} = water_state(state, {500, top})

    state.map
      |> Map.values()
      |> IO.inspect
      |> Enum.count(&(&1 in [:still, :flow]))
  end

  def part2(input) do
    map =
      input
      |> String.split("\n", strip: true)
      |> Stream.reject(&(&1 == ""))
      |> Stream.map(&parse_clay/1)
      |> generate_clay_map()

    {{_, top}, {_, bottom}} = map |> Map.keys |> Enum.min_max_by(&(elem(&1, 1)))

    state = %{
      map: map,
      top: top,
      bottom: bottom + 1
    }

    {_, state} = water_state(state, {500, top})

    state.map
      |> Map.values()
      |> Enum.count(&(&1 == :still))
  end

  defp water_state(%{bottom: bottom} = state, {_, bottom}) do
    {:flow, state}
  end

  defp water_state(state, water) do
    case Map.get(state.map, water, :sand) do
      :sand ->
        expand(state, water)
      :flow ->
        {:flow, state}
      x when x in [:still, :clay] ->
        {:still, state}
    end
  end

  defp expand(state, {x, y} = water) do
    state = %{state | map: Map.put(state.map, water, :still)}
    water_move_down = {x, y + 1}

    case water_state(state, water_move_down) do
      {:flow, state} ->
        {:flow, %{state | map: Map.put(state.map, water, :flow)}}

      {:still, state} ->
        {left_water_state, state} = water_state(state, {x - 1, y})
        {right_water_state, state} = water_state(state, {x + 1, y})

        water_state =
          if left_water_state == :flow or right_water_state == :flow do
            :flow
          else
            :still
          end

        state_map = Map.put(state.map, water, water_state)

        state_map =
          if water_state == :flow do
            state_map |> mark_flow(water, fn {x, y} -> {x-1, y} end) |> mark_flow(water, fn {x, y} -> {x+1, y} end)
          else
            state_map
          end

        {water_state, %{state | map: state_map}}
    end
  end

  defp mark_flow(state, water, fun) do
    fun.(water)
    |> Stream.iterate(fun)
    |> Stream.take_while(fn water -> Map.get(state, water, :sand) == :still end)
    |> Enum.reduce(state, fn water, state -> Map.put(state, water, :flow) end)
  end

  defp parse_clay(entry) do
    case parse_y_range(entry) do
      {:ok, [x, y1, y2], _, _, _, _} ->
        {x..x, y1..y2}
      _ ->
        {:ok, [y, x1, x2], _, _, _, _} = parse_x_range(entry)
        {x1..x2, y..y}
    end
  end

  defp generate_clay_map(clay_coordinates) do
    Enum.reduce(clay_coordinates, %{}, fn {x_range, y_range}, clay_map ->
        for x <- x_range,
          y <- y_range,
          point = {x, y},
          do: {point, :clay},
          into: clay_map
    end)
  end
end
