defmodule Telnet.Listener do
  use GenServer
  import Supervisor.Spec

  def start_link(ip, port) do
    GenServer.start_link(__MODULE__, [ip, port], [name: __MODULE__])
  end

  def init([ip, port]) do
    tcp_config = [:binary, packet: :line, active: true, ip: ip]
    {:ok, listen_socket} = :gen_tcp.listen(port, tcp_config)

    IO.inspect "Started listening..."
    send(self(), :start_client_supervisor)
    {:ok, %{listen_socket: listen_socket, clients_sup: nil}}
  end

  def handle_info(:start_client_supervisor, state = %{listen_socket: listen_socket}) do
    {:ok, clients_sup} = Supervisor.start_child(Telnet.Supervisor, clients_supervisor_spec(listen_socket))
    {:ok, _client} = Supervisor.start_child(Telnet.ClientsSupervisor, [])

    {:noreply, %{state | clients_sup: clients_sup}}
  end

  defp clients_supervisor_spec(listen_socket) do
    opts = [restart: :transient]
    supervisor(Telnet.ClientsSupervisor, [listen_socket], opts)
  end
end
