defmodule Wow do
  def sum([], total), do: total
  def sum([head | tail], total), do: sum(tail, total + head)

  def sum1([]), do: 0
  def sum1([head | tail]), do: head + sum1(tail)
end
