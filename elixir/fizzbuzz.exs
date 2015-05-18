fizzbuzz = fn
  (0, 0, _) -> IO.puts "FizzBuzz"
  (0, _, _) -> IO.puts "Fizz"
  (_, 0, _) -> IO.puts "Buzz"
  (_, _, c) -> IO.puts c
end

fizzbuzz.(0,0,1)
fizzbuzz.(0,2,1)
fizzbuzz.(1,0,1)
fizzbuzz.(5,5,1)

fb = fn
  n -> fizzbuzz.(rem(n, 3), rem(n, 5), n)
end

IO.puts '---------------------------'
[ fb.(10), fb.(11), fb.(12), fb.(13), fb.(14), fb.(15), fb.(16) ]


# With case

fb2 = fn(number) ->
  test = { rem(number, 3), rem(number, 5) }
  case test do
    {0, 0} ->
      IO.puts "Fizzbuzz"
    {0, _} ->
      IO.puts "Fizz"
    {_, 0} ->
      IO.puts "Buzz"
    _ ->
      IO.puts number
  end
end
IO.puts '---------------------------'
fb2.(45)
fb2.(9)
fb2.(10)
fb2.(11)

# With cond

fb3 = fn(n) ->
  cond do
    rem(n, 3) == 0 and rem(n, 5) == 0 -> "FizzBuzz"
    rem(n, 3) == 0 -> "Fizz"
    rem(n, 5) == 0 -> "Buzz"
    true -> n
  end
end
IO.puts '---------------------------'
IO.puts fb3.(45)
IO.puts fb3.(9)
IO.puts fb3.(10)
IO.puts fb3.(11)

