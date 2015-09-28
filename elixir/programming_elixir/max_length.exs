defmodule Wow do
  def max_length(list) do
    _max_length(list, 0)
  end

  defp _max_length([head | []], len) do
    if String.length(head) > len do
      String.length(head)
    else
      len
    end
  end

  defp _max_length([head | tail], len) do
    if String.length(head) > len do
      _max_length(tail, String.length(head))
    else
      _max_length(tail, len)
    end
  end

  # Better way
  def better_length(list) do
    list
    |> Enum.map_reduce(0, fn (word, current_length) -> { word, max(String.length(word), current_length) } end)
  end
end

IO.puts Wow.max_length(["hello", "world", "aaaaaaaaaa"])
IO.inspect elem(Wow.better_length(["hello", "world", "aaaaaaaaaa"]), 1)
