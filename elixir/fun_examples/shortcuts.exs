Enum.map([1,2,3,4], fn x -> x + 1 end)
|> IO.inspect

Enum.map([1,2,3,4], &(&1 + 1))
|> IO.inspect
