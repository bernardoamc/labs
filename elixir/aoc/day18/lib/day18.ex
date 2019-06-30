defmodule Day18 do
  def part1(input) do
    state =
      input
      |> String.split("\n", strip: true)
      |> Stream.reject(&(&1 == ""))
      |> Stream.with_index()
      |> Stream.flat_map(fn {line, y} -> line |> to_charlist() |> Stream.with_index() |> Stream.map(&{&1, y}) end)
      |> Stream.map(fn {{area, x}, y} -> parse_area(area, {x, y}) end)
      |> Enum.into(%{})
      |> pass_minutes({%{}, %{}}, 0, 10)

    groups =
      Enum.reduce(state, %{}, fn {_key, area}, grouped ->
        Map.update(grouped, area, 1, &(&1 + 1))
      end)

    Map.get(groups, :tree, 0) * Map.get(groups, :lumber, 0)
  end

  def part2(input) do
    state =
      input
      |> String.split("\n", strip: true)
      |> Stream.reject(&(&1 == ""))
      |> Stream.with_index()
      |> Stream.flat_map(fn {line, y} -> line |> to_charlist() |> Stream.with_index() |> Stream.map(&{&1, y}) end)
      |> Stream.map(fn {{area, x}, y} -> parse_area(area, {x, y}) end)
      |> Enum.into(%{})
      |> pass_minutes({%{}, %{}}, 0, 1_000_000_000)

    groups =
      Enum.reduce(state, %{}, fn {_key, area}, grouped ->
        Map.update(grouped, area, 1, &(&1 + 1))
      end)

    Map.get(groups, :tree, 0) * Map.get(groups, :lumber, 0)
  end

  defp parse_area(?|, coordinate), do: {coordinate, :tree}
  defp parse_area(?#, coordinate), do: {coordinate, :lumber}
  defp parse_area(?., coordinate), do: {coordinate, :open}

  defp pass_minutes(state, _seen, limit, limit), do: state

  defp pass_minutes(state, {seen_by_state, seen_by_minute}, current_minute, limit) do
    case Map.get(seen_by_state, state) do
      nil ->
        seen_by_state = Map.put(seen_by_state, state, current_minute)
        seen_by_minute = Map.put(seen_by_minute, current_minute, state)
        pass_minute(state, {seen_by_state, seen_by_minute}, current_minute, limit)
      minute_cycle ->
        cycle_length = current_minute - minute_cycle
        position_within_cycle = rem((limit - minute_cycle), cycle_length)
        Map.fetch!(seen_by_minute, minute_cycle + position_within_cycle)
    end
  end

  defp pass_minute(state, seen, current_minute, limit) do
    new_state =
      Enum.reduce(state, %{}, fn {coordinate, area}, new_state ->
        Map.put_new(new_state, coordinate, next_area_state(area, coordinate, state))
      end)

    pass_minutes(new_state, seen, current_minute + 1, limit)
  end

  defp next_area_state(:open, coordinate, state) do
    surroundings = adjacent_areas(coordinate, state)
    if Enum.count(surroundings, &(&1 == :tree)) >= 3, do: :tree, else: :open
  end

  defp next_area_state(:tree, coordinate, state) do
    surroundings = adjacent_areas(coordinate, state)
    if Enum.count(surroundings, &(&1 == :lumber)) >= 3, do: :lumber, else: :tree
  end

  defp next_area_state(:lumber, coordinate, state) do
    surroundings = adjacent_areas(coordinate, state)
    if Enum.member?(surroundings, :lumber) && Enum.member?(surroundings, :tree), do: :lumber, else: :open
  end

  defp adjacent_areas(coordinate, state) do
    [
      Map.get(state, up(coordinate)),
      Map.get(state, down(coordinate)),
      Map.get(state, left(coordinate)),
      Map.get(state, right(coordinate)),
      Map.get(state, up_left(coordinate)),
      Map.get(state, up_right(coordinate)),
      Map.get(state, down_left(coordinate)),
      Map.get(state, down_right(coordinate))
    ]
  end

  defp up({x,y}), do: {x, y - 1}
  defp down({x,y}), do: {x, y + 1}
  defp left({x,y}), do: {x - 1, y}
  defp right({x,y}), do: {x + 1, y}
  defp up_left({x,y}), do: {x - 1, y - 1}
  defp up_right({x,y}), do: {x + 1, y - 1}
  defp down_left({x,y}), do: {x - 1, y + 1}
  defp down_right({x,y}), do: {x + 1, y + 1}
end
