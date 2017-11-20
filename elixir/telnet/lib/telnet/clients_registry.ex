defmodule Telnet.ClientsRegistry do
  use GenServer

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    {:ok, MapSet.new}
  end

  def add(client_socket) do
    GenServer.cast(__MODULE__, {:add, client_socket})
  end

  def remove(client_socket) do
    GenServer.cast(__MODULE__, {:remove, client_socket})
  end

  def broadcast(sender_socket, packet) do
    GenServer.cast(__MODULE__, {:broadcast, sender_socket, packet})
  end

  def handle_cast({:broadcast, sender_socket, packet}, clients_sockets) do
    Enum.each clients_sockets, fn client_socket ->
      unless sender_socket == client_socket do
        :gen_tcp.send(client_socket, "> #{packet}")
      end
    end

    {:noreply, clients_sockets}
  end

  def handle_cast({:add, client_socket}, clients_sockets) do
    {:noreply, MapSet.put(clients_sockets, client_socket)}
  end

  def handle_cast({:remove, client_socket}, clients_sockets) do
    {:noreply, MapSet.delete(clients_sockets, client_socket)}
  end
end
