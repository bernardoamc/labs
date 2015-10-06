run_query = fn(query_def) ->
  :timer.sleep(2000)
  "#{query_def} result"
end

async_query = fn(query_def) ->
  spawn(fn -> IO.puts(run_query.(query_def)) end)
end

Enum.each(1..5, &async_query.("query #{&1}"))
:timer.sleep 5000
