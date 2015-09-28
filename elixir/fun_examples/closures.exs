add_n = fn n ->
  fn x -> n + x end
end

add_two = add_n.(2)
add_five = add_n.(5)

IO.puts add_two.(5)
IO.puts add_five.(2)
