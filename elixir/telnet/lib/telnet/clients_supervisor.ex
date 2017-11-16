defmodule Telnet.ClientsSupervisor do
  use Supervisor

  def start_link(listen_socket) do
    Supervisor.start_link(__MODULE__, [listen_socket], [name: __MODULE__])
  end

  def init([listen_socket]) do
    IO.inspect "Clients Supervisor ready..."

    opts = [
      strategy: :simple_one_for_one,
      max_restarts: 5,
      max_seconds: 5
    ]

    children = [
      worker(Telnet.Client, [listen_socket], restart: :transient),
    ]

    supervise(children, opts)
  end
end
