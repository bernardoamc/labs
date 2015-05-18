defmodule Wow do
  def map([], _fun), do: []
  def map([head | tail], fun), do: [fun.(head) | map(tail, fun)]
end
