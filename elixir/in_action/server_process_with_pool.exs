defmodule DatabaseServer do
  def start do
    spawn(&loop/0)
  end

  def run_async(server_pid, query_def) do
    send(server_pid, {:run_query, self, query_def})
  end

  def get_result do
    receive do
      {:query_result, result} -> result
    after 5000 ->
      {:error, :timeout}
    end
  end

  defp loop do
    receive do
      {:run_query, caller, query_def} ->
        send(caller, {:query_result, run_query(query_def)})
    end

    loop
  end

  defp run_query(query_def) do
    :timer.sleep(2000)
    "#{query_def} result"
  end
end

pool = Enum.map(1..100, fn(_) -> DatabaseServer.start end)

Enum.each(1..5, fn(query_def) ->
  server_pid = Enum.at(pool, :random.uniform(100) -1)
  DatabaseServer.run_async(server_pid, query_def)
end)

Enum.map(1..5, fn(_) -> DatabaseServer.get_result end) |> IO.inspect
