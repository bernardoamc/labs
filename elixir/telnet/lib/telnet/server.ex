defmodule Telnet.Server do
  use Supervisor

  def start_link(ip, port) do
    IO.inspect ip
    IO.inspect port
    Supervisor.start_link(__MODULE__, [ip, port], [name: __MODULE__])
  end

  def init([ip, port]) do
    tcp_config = [:binary, packet: :line, active: true, ip: ip]
    {:ok,listen_socket}= :gen_tcp.listen(port, tcp_config)

    opts = [
      strategy: :one_for_one,
      max_restarts: 5,
      max_seconds: 5
    ]

    children = [
      worker(Telnet.Acceptor, [listen_socket], [id: :worker_1]),
      worker(Telnet.Acceptor, [listen_socket], [id: :worker_2]),
      worker(Telnet.Acceptor, [listen_socket], [id: :worker_3]),
      worker(Telnet.Acceptor, [listen_socket], [id: :worker_4]),
      worker(Telnet.Acceptor, [listen_socket], [id: :worker_5])
    ]

    supervise(children, opts)
  end
end
