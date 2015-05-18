defmodule Wow do
  # All
  def all?([], _), do: true

  def all?([head | tail], fun) do
    if fun.(head) do
      all?(tail, fun)
    else
      false
    end
  end

  # Each
  def each([], _), do: :ok
  def each([head | tail], fun) do
    fun.(head)
    each(tail, fun)
  end

  def filter([], _), do: []
  def filter([head | tail], fun) do
    if fun.(head) do
      [head | filter(tail, fun)]
    else
      filter(tail, fun)
    end
  end

  def split(list, count), do: _split(list, [], count)
  defp _split([], front, 0), do: [Enum.reverse(front), []]
  defp _split(tail, front, 0), do: [Enum.reverse(front), tail]
  defp _split([head | tail], front, count), do: _split(tail, [head | front], count-1)

  def take(list, count), do: hd(split(list, count))
end

IO.puts Wow.all?([1,2,3,4], &(&1 < 5))
IO.puts Wow.all?([1,2,3,4], &(&1 < 3))

Wow.each([1,2,3,4], &IO.puts/1)

IO.inspect Wow.filter([1,2,3,4,5], &(&1 > 3))

IO.inspect Wow.split([1,2,3,4,5], 3)

IO.inspect Wow.take([1,2,3,4,5], 3)
