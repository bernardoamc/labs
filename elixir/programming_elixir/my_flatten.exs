defmodule Wow do
  def flatten([]), do: []
  def flatten([head | tail]), do: flatten(head) ++ flatten(tail)
  def flatten(head), do: [head]

  def jvflatten(list), do: _jvflatten(list, [])

  def _jvflatten([head | tail], next) when is_list(head) do
    _jvflatten(head, _jvflatten(tail, next))
  end

  def _jvflatten([head | tail], next) do
    [head | _jvflatten(tail, next)]
  end

  def _jvflatten([], next) do
    next
  end
end

IO.inspect Wow.flatten([ 1, [ 2, 3, [4] ], 5, [[[6]]]])
IO.inspect Wow.jvflatten([ 1, [ 2, 3, [4] ], 5, [[[6]]]])
