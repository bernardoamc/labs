defmodule List do
  def len([]), do: 0
  def len([_head | tail]), do: 1 + length(tail)
end

IO.puts List.len([1,2,3,4])
