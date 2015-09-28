defmodule Ticker do
  @interval 2000
  @name :ticker

  def start do
    pid = spawn(__MODULE__, :generator, [[], 0])
    :global.register_name(@name, pid)
  end

  def register(client_pid) do
    send :global.whereis_name(@name), { :register, client_pid }
  end

  def generator([], position) do
    receive do
      { :register, pid } ->
        IO.puts "registering #{inspect pid}"
        generator([pid], position)
    end
  end

  def generator(clients, position) do
    receive do
      { :register, pid } ->
        IO.puts "registering #{inspect pid}"
        generator([pid|clients], position + 1)
    after
      @interval ->
        Enum.at(clients, position) |> send {:tick, position}
        next_pos = (position + 1 >= Enum.count(clients)) && 0 || position + 1
        generator(clients, next_pos)
    end
  end
end

defmodule Client do
  def start do
    pid = spawn(__MODULE__, :receiver, [])
    Ticker.register(pid)
  end

  def receiver do
    receive do
      { :tick, position } ->
        IO.puts "tock in client at position #{position}"
        receiver
    end
  end
end
