defmodule Wow do
  def span(to, to), do: [to]
  def span(from, to), do: [from | span(from + 1, to)]

  def prime?(2), do: true
  def prime?(3), do: true
  def prime?(x), do: Enum.all?(span(2, trunc(:math.sqrt x)), &(rem(x, &1) !== 0))

  def primes(n) do
    for x <- span(2,n), prime?(x), do: x
  end
end

IO.inspect Wow.primes(30)
