# iex(2)> quote do: 1 + 2 * 3
#   {:+, [context: Elixir, import: Kernel],
#     [1, {:*, [context: Elixir, import: Kernel], [2, 3]}]}

defmodule Humanize do
  defmacro operation(operator, name, from, by) do
    quote do
      def explain(unquote(operator), _, [left, right]) when is_number(left) and is_number(right) do
        "#{unquote(name)} #{left} #{unquote(from)} #{right}"
      end

      def explain(unquote(operator), _, [left, right]) when is_number(left) do
        "#{explain(right)} then #{unquote(name)} #{unquote(from)} #{left}"
      end
    end
  end
end

defmodule Translate do
  require Humanize

  Humanize.operation(:+, "add", "to", "")
  Humanize.operation(:-, "subtract", "from", "")
  Humanize.operation(:*, "multiply", "by", "by")
  Humanize.operation(:/, "divide", "into", "by")

  defmacro expression({operation, _, [left, right]}) do
    IO.inspect operation
    IO.inspect left
    IO.inspect right
    explain(operation, 5, [left, right])
  end
end

defmodule Test do
  require Translate

  IO.puts Translate.expression 1 + 2
  IO.puts Translate.expression 1 + 2 + 3
end
