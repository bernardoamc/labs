defmodule Day4 do
  import NimbleParsec

  defparsec :parse_guard_schedule,
    ignore(string("["))
    |> integer(4)
    |> ignore(string("-"))
    |> integer(2)
    |> ignore(string("-"))
    |> integer(2)
    |> ignore(string(" "))
    |> integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string("] "))
    |> choice([
        ignore(string("Guard #")) |> integer(min: 1) |> ignore(string(" begins shift")) |> unwrap_and_tag(:shift),
        ignore(string("falls asleep")) |> replace(:sleep),
        ignore(string("wakes up")) |> replace(:wakeup)
      ])

  def part1(input) do
    sleep_grouped_by_id_and_date = input
    |> String.split("\n", trim: true)
    |> Enum.map(&normalize_input/1)
    |> Enum.sort()
    |> group_by_id_and_date([])

    id = sleep_grouped_by_id_and_date
      |> compute_guard_sleep_most()

    minute_sleep_the_most = sleep_grouped_by_id_and_date
      |> compute_minute_sleep_most(id)

      id * minute_sleep_the_most
  end

  def part2(input) do
    {{id, minute}, _} = input
      |> String.split("\n", trim: true)
      |> Enum.map(&normalize_input/1)
      |> Enum.sort()
      |> group_by_id_and_date([])
      |> compute_times_per_id_and_minute()
      |> Enum.max_by(fn {_id_and_minute, times } -> times end)

    id * minute
  end

  def normalize_input(line) do
    {:ok, [year, month, day, hour, minute, action], _, _, _, _} = parse_guard_schedule(line)
    {{year, month, day}, hour, minute, action}
  end

  defp group_by_id_and_date([{date, _hour, _minute, {:shift, id}} | rest], groups) do
    {rest, ranges} = build_sleep_ranges(rest, [])
    group_by_id_and_date(rest, [{id, date, ranges} | groups])
  end

  defp group_by_id_and_date([], groups) do
    groups
  end

  defp build_sleep_ranges([{_, _, down, :sleep}, {_, _, up, :wakeup} | rest], ranges) do
    build_sleep_ranges(rest, [down..(up - 1) | ranges])
  end

  defp build_sleep_ranges(rest, ranges) do
    {rest, Enum.reverse(ranges) }
  end

  defp compute_guard_sleep_most(groups) do
    sleep_per_guard = Enum.reduce(groups, %{}, fn {id, _date, ranges}, acc ->
      sleep_amount = Enum.map(ranges, &Enum.count/1) |> Enum.sum()
      Map.update(acc, id, sleep_amount, &(&1 + sleep_amount))
    end)

    {id, _} = Enum.max_by(sleep_per_guard, fn {_, sleep_amount } -> sleep_amount end)
    id
  end

  defp compute_minute_sleep_most(groups, id) do
    minutes =
      for {^id, _, ranges} <- groups,
        range <- ranges,
        minute <- range,
        do: minute

    sleep_times_per_minute = Enum.reduce(minutes, %{}, fn minute, acc ->
      Map.update(acc, minute, 1, &(&1+1))
    end)

    {minute, _} = Enum.max_by(sleep_times_per_minute, fn {_minute, times } -> times end)

    minute
  end

  defp compute_times_per_id_and_minute(groups) do
    Enum.reduce(groups, %{}, fn {id, _date, ranges}, acc ->
      Enum.reduce(ranges, acc, fn range, acc ->
        Enum.reduce(range, acc, fn minute, acc ->
          Map.update(acc, {id, minute}, 1, &(&1+1))
        end)
      end)
    end)
  end
end
