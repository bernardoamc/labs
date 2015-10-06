defmodule DatabaseServer do
  def start do
    spawn(fn ->
      initial_state = :random.uniform(1000)
      loop(initial_state)
    end)
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

  defp loop(state) do
    receive do
      {:run_query, caller, query_def} ->
        query_result = run_query(state, query_def)
        send(caller, {:query_result, query_result})
    end

    loop(state)
  end

  defp run_query(state, query_def) do
    :timer.sleep(2000)
    "State #{state}: #{query_def} result"
  end
end

server_pid = DatabaseServer.start

DatabaseServer.run_async(server_pid, "query 1")
DatabaseServer.get_result |> IO.inspect

DatabaseServer.run_async(server_pid, "query 2")
DatabaseServer.get_result |> IO.inspect

