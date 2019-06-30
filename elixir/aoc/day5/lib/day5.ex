defmodule Day5 do
  def part1(input) do
    input
      |> String.trim()
      |> compute_reaction()
      |> length()
  end

  def part2(input) do
    input
      |> String.trim()
      |> compute_smallest_after_unit_removal()
  end

  def compute_smallest_after_unit_removal(polymers) do
    {:ok, smallest} = ?a..?z
    |> Task.async_stream(fn char ->
      reaction = remove_unit(polymers, char, []) |> compute_reaction()
      length(reaction)
    end, max_concurrency: 16)
    |> Enum.min()

    smallest
  end

  def remove_unit(<<polymer, polymers::binary>>, unit, acc) when (polymer == unit) or abs(polymer - unit) == 32 do
    remove_unit(polymers, unit, acc)
  end

  def remove_unit(<<polymer, polymers::binary>>, unit, acc) do
    remove_unit(polymers, unit, [polymer | acc])
  end

  def remove_unit(<<>>, _, acc) do
    Enum.reverse(acc) |> List.to_string()
  end

  def compute_reaction(<<p1, rest::binary>>) do
    compute_reaction(rest, [p1])
  end

  defp compute_reaction(<<p1, polymers::binary>>, [p2 | rest]) when abs(p1 - p2) == 32 do
    compute_reaction(polymers, rest)
  end

  defp compute_reaction(<<p1, polymers::binary>>, acc) do
    compute_reaction(polymers, [p1 | acc])
  end

  defp compute_reaction(<<>>, acc) do
    Enum.reverse(acc)
  end
end
