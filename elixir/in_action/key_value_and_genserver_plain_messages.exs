defmodule KeyValueStore do
  use GenServer

  def init(_) do
    :timer.send_interval(5000, :cleanup)
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

  # Handles plain messages that are not "call" or "cast". Since we redefined
  # this function we have to add an additional handle_info function that
  # catches all unexpected messages. This is what GenServer does when
  # we don't define our own handle_info function.
  def handle_info(:cleanup, state) do
    IO.puts "performing cleanup..."
    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}
end

{:ok, pid} = KeyValueStore.start
KeyValueStore.put(pid, :some_key, :some_value)
KeyValueStore.get(pid, :some_key) |> IO.inspect
:timer.sleep(10000)
