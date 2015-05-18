# The first element of the tuple returned by "fn" is the value returned by unfold
# The second will be used as the initial value of the next iteration
# In this case:
# {0,1} -> {0, {1, 0 + 1}}  => 0 returned
# {1,1} -> {1, {1, 1 + 1}}  => 1 returned
# {1,2} -> {1, {2, 1 + 2}}  => 1 returned
# {2,3} -> {2, {3, 2 + 3}}  => 2 returned
# {3,5} -> {3, {5, 3 + 5}}  => 3 returned
# {5,8} -> and so on...
IO.inspect Stream.unfold({0,1}, fn {f1, f2} -> {f1, {f2, f1 + f2}} end) |> Enum.take(10)
