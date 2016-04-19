defmodule ControlFlow do
  defmacro unless(expression, do: block) do
    quote do
      if !unquote(expression), do: unquote(block)
    end
  end
end

defmodule MoreControlFlow do
  defmacro unless(expression, do: block) do
    quote do
      cond do
        !unquote(expression) ->
          unquote(block)
        true ->
          nil
      end
    end
  end
end
