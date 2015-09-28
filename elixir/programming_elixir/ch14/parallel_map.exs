defmodule Parallel do
  def pmap(collection, fun)  do
    my_pid = self

    collection
    |> Enum.map(fn (elem) ->
         spawn_link fn -> (send my_pid, { self, fun.(elem) }) end # This anonymous function will be executed by spawn_link
       end)
    |> Enum.map(fn (pid) ->
         receive do { ^pid, result } -> result end
       end)
  end
end

IO.inspect Parallel.pmap 1..10, &(&1 * &1)
