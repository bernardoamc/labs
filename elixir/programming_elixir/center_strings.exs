defmodule Wow do
  def center(strings) do
    strings
    |> Enum.map_reduce(0, &(max_length(&1, &2)))
    |> center_strings
    |> Enum.each(&IO.puts &1)
  end

  defp max_length(string, current_length) do
    length = String.length string
    { {string, length}, max(length, current_length) }
  end

  defp center_strings({ strings, max_length }) do
    Enum.map(strings, &(center_string(&1, max_length)))
  end

  defp center_string({ string, length }, max_length) do
    "#{String.duplicate(" ", div(max_length - length, 2))}#{string}"
  end
end

Wow.center(["cat", "zebra", "elephant"])
