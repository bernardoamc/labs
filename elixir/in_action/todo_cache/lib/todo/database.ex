defmodule Todo.Database do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :database_server)
  end

  def init(db_folder) do
    {:ok, start_workers(db_folder)}
  end

  defp start_workers(db_folder) do
    Enum.reduce(0..2, HashDict.new, fn(key, dict) ->
      {:ok, worker_pid} = Todo.DatabaseWorker.start(db_folder)
      HashDict.put(dict, key, worker_pid)
    end)
  end

  def store(key, data) do
    key
    |> get_worker
    |> GenServer.cast({:store, key, data})
  end

  def get(key) do
    key
    |> get_worker
    |> GenServer.call({:get, key})
  end

  def get_worker(key) do
    worker_key = :erlang.phash2(key, 3)
    GenServer.call(:database_server, {:get_worker, worker_key})
  end

  def handle_call({:get_worker, key}, _, workers) do
    {:reply, HashDict.get(workers, key), workers}
  end
end
