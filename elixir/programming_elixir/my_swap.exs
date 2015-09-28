defmodule Wow do
  def swap([]), do: []
  def swap([a]), do: [a]
  def swap([a, b | tail]), do: [b, a | swap(tail)]
end
