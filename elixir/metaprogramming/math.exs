defmodule Math do
  # {:+, [context: Elixir, import: Kernel], [5, 2]}
  defmacro say({:+, _, [lhs, rhs]}) do
    quote do
      lhs = unquote(lhs)
      rhs = unquote(rhs)

      result = lhs + rhs
      IO.puts "#{lhs} plus #{rhs} is #{result}"

      result
    end
  end

  defmacro say({:*, _, [lhs, rhs]}) do
    quote do
      lhs = unquote(lhs)
      rhs = unquote(rhs)

      result = lhs * rhs
      IO.puts "#{lhs} times #{rhs} is #{result}"

      result
    end
  end
end
