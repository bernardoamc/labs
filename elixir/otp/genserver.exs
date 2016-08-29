defmodule Calculator do
  use GenServer

  def start do
    # The second argument of start/1 will be passed to init/1.
    GenServer.start(Calculator, nil)
  end

  def value(server_pid) do
    GenServer.call(server_pid, :value)
  end

  def add(server_pid, value) do
    GenServer.cast(server_pid, {:add, value})
  end

  def sub(server_pid, value) do
    GenServer.cast(server_pid, {:sub, value})
  end

  def init(_) do
    {:ok, 0}
  end

  # The second argument to handle_call/3 is a tuple that contains the request
  # ID (used internally by the gen_server behaviour) and the pid of the caller.
  def handle_call(:value, _, state) do
    # Meaning: {:reply, response, new_state}
    {:reply, state, state}
  end

  def handle_cast({:add, value}, state) do
    {:noreply, state + value}
  end

  def handle_cast({:sub, value}, state) do
    {:noreply, state - value}
  end
end

# Checking that "use GenServer" injects some functions in our module.
IO.inspect Calculator.__info__(:functions)

{:ok, pid} = Calculator.start()
Calculator.add(pid, 5)
IO.inspect Calculator.value(pid)
Calculator.sub(pid, 2)
IO.inspect Calculator.value(pid)
Calculator.sub(pid, 1)
Calculator.add(pid, 2)
IO.inspect Calculator.value(pid)
