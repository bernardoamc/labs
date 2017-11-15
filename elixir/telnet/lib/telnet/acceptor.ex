defmodule Telnet.Acceptor do
  use GenServer

  def start_link(listen_socket) do
    GenServer.start_link(__MODULE__, [listen_socket])
  end

  def init([listen_socket]) do
    send(self(), :start_accepting)
    {:ok, %{listen_socket: listen_socket, server_socket: nil}}
  end

  def handle_info(:start_accepting, state = %{listen_socket: listen_socket}) do
    server_socket = :gen_tcp.accept listen_socket
    {:noreply, %{state | server_socket:  server_socket}}
  end

  def handle_info({:tcp, client_socket, packet}, state) do
    Task.Supervisor.start_child(
      Telnet.ClientsSupervisor,
      fn -> Telnet.Client.receive({client_socket, packet}) end
    )
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _client_socket}, state) do
    IO.inspect "Socket has been closed"
    {:noreply, state}
  end

  def handle_info({:tcp_error, client_socket, reason}, state) do
    IO.inspect client_socket, label: "connection closed dut to #{reason}"
    {:noreply, state}
  end
end
