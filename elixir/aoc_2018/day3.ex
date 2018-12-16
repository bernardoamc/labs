defmodule Day3 do
  import NimbleParsec

      #1 @ 1,3: 4x4
  defparsec :parse_claim,
    ignore(string("#"))
    |> integer(min: 1)
    |> ignore(string(" @ "))
    |> integer(min: 1)
    |> ignore(string(","))
    |> integer(min: 1)
    |> ignore(string(": "))
    |> integer(min: 1)
    |> ignore(string("x"))
    |> integer(min: 1)

  def part1(input) do
    overlapped_count = input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn claim, acc ->
      {:ok, [_id, left, top, width, heigh], _, _, _, _} = parse_claim(claim)

      horizontal_range = (left + 1)..(left + width)
      vertical_range = (top + 1)..(top + heigh)
      Enum.reduce(horizontal_range, acc, fn x, acc ->
        Enum.reduce(vertical_range, acc, fn y, acc ->
          Map.update(acc, {x,y}, 1, &(&1+1))
        end)
      end)
    end)

    for {_pos, count} <- overlapped_count do
      if count > 1, do: 1, else: 0
    end
    |> Enum.sum()
  end

  def part2(input) do
    parsed_claims = input
    |> String.split("\n", trim: true)
    |> Enum.map(fn claim ->
      {:ok, result, _, _, _, _} = parse_claim(claim)
      result
    end)

    overlapped_ids =
      parsed_claims
      |> Enum.reduce(%{}, fn [id, left, top, width, heigh], acc ->
      horizontal_range = (left + 1)..(left + width)
      vertical_range = (top + 1)..(top + heigh)
      Enum.reduce(horizontal_range, acc, fn x, acc ->
        Enum.reduce(vertical_range, acc, fn y, acc ->
          Map.update(acc, {x,y}, [id], &([id | &1]))
        end)
      end)
    end)

    [id, _, _, _, _] = Enum.find(parsed_claims, fn [id, left, top, width, heigh] ->
      horizontal_range = (left + 1)..(left + width)
      vertical_range = (top + 1)..(top + heigh)

      Enum.all?(horizontal_range, fn x ->
        Enum.all?(vertical_range, fn y ->
          Map.get(overlapped_ids, {x, y}) == [id]
        end)
      end)
    end)

    id
  end
end
