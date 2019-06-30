defmodule Day1 do
  def compute_frequency(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(fn line -> String.to_integer(line) end)
    |> Enum.sum()
  end

  def find_seen_frequency(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(fn line -> String.to_integer(line) end)
    |> Stream.cycle()
    |> Enum.reduce_while({0, []}, fn change, {current, seen} ->
      new_frequency = change + current

      if new_frequency in seen do
        {:halt, new_frequency}
      else
        {:cont, {new_frequency, [new_frequency | seen]}}
      end
    end)
  end
end
