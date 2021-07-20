defmodule CircularList do
  def new(elements), do: {elements, []}

  def next({[], previous}), do: next({Enum.reverse(previous), []})
  def next({[current | rest], previous}), do: {rest, [current | previous]}

  def previous({next, []}), do: previous({[], Enum.reverse(next)})
  def previous({next, [last | rest]}), do: {[last | next], rest}

  def insert({next, previous}, element), do: {[element | next], previous}

  def pop({[], previous}), do: pop({Enum.reverse(previous), []})
  def pop({[current | rest], previous}), do: {current, {rest, previous}}
end
