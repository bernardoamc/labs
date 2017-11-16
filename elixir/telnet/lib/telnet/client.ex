defmodule Telnet.Client do
  use GenServer

  def start_link(listen_socket) do
    GenServer.start_link(__MODULE__, [listen_socket])
  end

  def init([listen_socket]) do
    send(self(), :accept)
    {:ok, %{listen_socket: listen_socket, server_socket: nil}}
  end

  def handle_info(:accept, state = %{listen_socket: listen_socket}) do
    IO.inspect "Ready to accept connections..."
    {:ok, server_socket} = :gen_tcp.accept listen_socket
    Supervisor.start_child(Telnet.ClientsSupervisor, [])

    {:noreply, %{state | server_socket: server_socket}}
  end

  def handle_info({:tcp, client_socket, packet}, state) do
    IO.inspect "Packet received: #{packet}"
    :gen_tcp.send client_socket,"Command acknowledged... \n"
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _client_socket}, %{ server_socket: server_socket }) do
    IO.inspect "Socket has been closed"
    {:stop, :normal, server_socket}
  end

  def handle_info({:tcp_error, _client_socket, reason}, %{ server_socket: server_socket }) do
    IO.inspect "connection closed due to #{reason}"
    {:stop, :normal, server_socket}
  end

  def terminate(_reason, server_socket) do
    IO.inspect "Terminating GenServer"
    :gen_tcp.close(server_socket)
    :ok
  end
end
