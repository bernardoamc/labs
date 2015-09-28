ok! = fn
  {:ok, data } -> IO.inspect data
  invalid -> raise "Invalid parameter #{inspect invalid}"
end

ok!.(File.open("raise.exs"))
#ok!.(File.open("somefile"))

# Or

ok2! = fn(p) ->
  case p do
    {:ok, data } -> IO.inspect data
    invalid -> raise "Invalid parameter #{inspect invalid}"
  end
end

ok2!.(File.open("raise.exs"))
ok2!.(File.open("somefile"))
