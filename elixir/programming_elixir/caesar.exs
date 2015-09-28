defmodule Wow do
  def caesar(list, n), do: _caesar(list, n)

  defp _caesar([], _), do: []
  defp _caesar([head | tail], n) when head + n > ?z, do: [ '?' | _caesar(tail, n)]
  defp _caesar([head | tail], n), do: [ head + n | _caesar(tail, n)]
end
