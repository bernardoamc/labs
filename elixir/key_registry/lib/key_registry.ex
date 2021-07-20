defmodule KeyRegistry do
  use GenServer

  ## Client

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def write(pid, {_key, _value} = entry) do
    GenServer.cast(pid, {:write, entry})
  end

  def read(pid, key) do
    GenServer.call(pid, {:read, key})
  end

  def delete(pid, key) do
    GenServer.cast(pid, {:delete, key})
  end

  def clear(pid) do
    GenServer.cast(pid, :clear)
  end

  def exist?(pid, key) do
    GenServer.call(pid, {:exist?, key})
  end

  def stop(pid) do
    GenServer.cast(pid, :stop)
  end

  ## Server

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:read, key}, _from, registry) do
    {:reply, Map.fetch(registry, key), registry}
  end

  def handle_call({:exist?, key}, _from, registry) do
    {:reply, Map.has_key?(registry, key), registry}
  end

  def handle_cast({:write, {key, value}}, registry) do
   new_registry = case Map.has_key?(registry, key) do
      true ->
        Map.update!(registry, key, fn _oldval -> value end)
      false ->
        Map.put_new(registry, key, value)
    end

    {:noreply, new_registry}
  end

  def handle_cast({:delete, key}, registry) do
    new_registry = Map.delete(registry, key)
    {:noreply, new_registry}
  end

  def handle_cast(:clear, _registry) do
    {:noreply, %{}}
  end

  def handle_cast(:stop, registry) do
    {:stop, :normal, registry}
  end

  # Invoked when the GenServer receives a message that don't have
  # an associated handle_call or handle_cast. We just keep the state
  # in this case.
  def handle_info(msg, registry) do
    IO.puts "received #{inspect msg}"
    {:noreply, registry}
  end

  # Invoked when handle_call or handle_cast return the :stop symbol
  def terminate(reason, registry) do
    IO.puts "server terminated because of #{inspect reason}"
    IO.inspect registry
    :ok
  end
end
