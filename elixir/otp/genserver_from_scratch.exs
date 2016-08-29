defmodule GenericServer do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init
      loop(callback_module, initial_state)
    end)
  end

  def loop(callback_module, state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} = callback_module.handle_call(request, state)
        send(caller, {:ok, response})
        loop(callback_module, new_state)
      {:cast, request} ->
        new_state = callback_module.handle_cast(request, state)
        loop(callback_module, new_state)
    end
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self})

    receive do
      {:ok, response} -> response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end
end

defmodule Calculator do
  def start() do
    GenericServer.start(Calculator)
  end

  def init do
    0
  end

  def value(server_pid) do
    GenericServer.call(server_pid, :value)
  end

  def add(server_pid, value) do
    GenericServer.cast(server_pid, {:add, value})
  end

  def sub(server_pid, value) do
    GenericServer.cast(server_pid, {:sub, value})
  end

  def handle_call(:value, state) do
    {state, state}
  end

  def handle_cast({:add, value}, state) do
    state + value
  end

  def handle_cast({:sub, value}, state) do
    state - value
  end
end


pid = Calculator.start()
Calculator.add(pid, 5)
IO.inspect Calculator.value(pid)
Calculator.sub(pid, 2)
IO.inspect Calculator.value(pid)
Calculator.sub(pid, 1)
Calculator.add(pid, 2)
IO.inspect Calculator.value(pid)
