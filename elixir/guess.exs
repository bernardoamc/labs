defmodule Guess do
  def guess(actual, lower..higher) do
    guess = div(lower + higher, 2)
    IO.puts "It is #{guess}"

    guessed(actual, lower..higher, guess)
  end

  defp guessed(actual, _, guess) when actual === guess do
    IO.puts "It is #{actual}"
  end

  defp guessed(actual, lower.._higher, guess) when actual < guess do
    guess(actual, lower..guess-1)
  end

  defp guessed(actual, _lower..higher, guess) when actual > guess do
    guess(actual, guess+1..higher)
  end
end

Guess.guess(273, 1..1000)
