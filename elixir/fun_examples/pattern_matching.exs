swap = fn {a, b} -> {b, a} end
IO.inspect swap.({1, 3})

# -------------------------------------------------------------

handle_open = fn
  {:ok, file} -> "Read data: #{IO.read(file, :line)}"
  {_,  error} -> "Error: #{:file.format_error(error)}"
end

handle_open.(File.open("./pattern_matching.exs"))
|> IO.puts

# -------------------------------------------------------------

defmodule Plus do
  def plus_1([]), do: []
  def plus_1([head | tail]), do: [head + 1 | plus_1(tail)]

  def map([], _fn), do: []
  def map([head | tail], fun), do: [fun.(head) | map(tail, fun)]

  def something([], _), do: nil
  def something([head | _tail], 0), do: head
  def something([head | tail], index), do: something(tail, index - 1)
end

Plus.plus_1([1,2,3])
|> IO.inspect

Plus.something([4, 6, 8, 10], 2)
|> IO.inspect

double = fn x -> x * 2 end
Plus.map([1,2,3], double) |> IO.inspect
