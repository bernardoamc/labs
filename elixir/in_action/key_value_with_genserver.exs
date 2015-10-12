defmodule KeyValueStore do
  use GenServer

  def init(_) do
    {:ok, HashDict.new}
  end

  def start do
    GenServer.start(KeyValueStore, nil)
  end

  def put(pid, key, value) do
    GenServer.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def handle_cast({:put, key, value}, state) do
    {:noreply, HashDict.put(state, key, value)}
  end

  def handle_call({:get, key}, _, state) do
    {:reply, HashDict.get(state, key), state}
  end
end

{:ok, pid} = KeyValueStore.start
KeyValueStore.put(pid, :some_key, :some_value)
KeyValueStore.get(pid, :some_key) |> IO.inspect
