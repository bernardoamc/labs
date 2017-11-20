defmodule Telnet.Client do
  use GenServer

  def start_link(listen_socket) do
    GenServer.start_link(__MODULE__, [listen_socket])
  end

  def init([listen_socket]) do
    send(self(), :accept)
    {:ok, %{listen_socket: listen_socket, client_socket: nil}}
  end

  def handle_info(:accept, state = %{listen_socket: listen_socket}) do
    {:ok, client_socket} = :gen_tcp.accept listen_socket
    Supervisor.start_child(Telnet.ClientsSupervisor, [])
    Telnet.ClientsRegistry.add(client_socket)
    Telnet.ClientsRegistry.broadcast(client_socket, "Someone joined...\n")

    {:noreply, %{state | client_socket: client_socket}}
  end

  def handle_info({:tcp, client_socket, packet}, state)  do
    {:ok, _pid} = Task.Supervisor.start_child(
      Telnet.CommandsSupervisor,
      fn -> Telnet.Command.parse(client_socket, packet) end
    )

    {:noreply, state}
  end

  def handle_info({:tcp_closed, client_socket}, _state) do
    Telnet.ClientsRegistry.broadcast(client_socket, "Someone quit...\n")
    {:stop, :normal, client_socket}
  end

  def handle_info({:tcp_error, client_socket, _reason}, _state) do
    Telnet.ClientsRegistry.broadcast(client_socket, "Someone quit...\n")
    {:stop, :normal, client_socket}
  end

  def terminate(_reason, client_socket) do
    Telnet.ClientsRegistry.remove(client_socket)
    :gen_tcp.close(client_socket)
    :ok
  end
end
