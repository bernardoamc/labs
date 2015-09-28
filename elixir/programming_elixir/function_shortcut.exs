IO.inspect (Enum.map [1,2,3,4], &(&1 + 2))
Enum.map [1,2,3,4], &(IO.inspect(&1))
