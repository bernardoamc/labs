defmodule Wow do
  def mapsum([], _), do: 0
  def mapsum([head | tail], fun), do: fun.(head) + mapsum(tail, fun)

  # Another approach in terms of map and reduce
  def map([], _), do: []
  def map([head | tail], fun), do: [fun.(head) | map(tail, fun)]

  def reduce([], value, _), do: value
  def reduce([head | tail], value, fun), do: reduce(tail, fun.(head, value), fun)

  def mapsum1(list, fun), do: map(list, fun) |> reduce(0, &(&1 + &2))
end
