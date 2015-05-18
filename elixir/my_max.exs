defmodule Wow do
  def max([head | tail]), do: _max(tail, head)

  defp _max([], greatest), do: greatest
  defp _max([head | tail], greatest) when head > greatest, do: _max(tail, head)
  defp _max([_head | tail], greatest), do: _max(tail, greatest)
end
