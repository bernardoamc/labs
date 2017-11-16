defmodule Telnet.Supervisor do
  use Supervisor

  def start_link(server_config) do
    Supervisor.start_link(__MODULE__, server_config, name: __MODULE__)
  end

  def init(server_config = [_, _]) do
    children = [
      worker(Telnet.Listener, server_config),
    ]

    opts = [strategy: :one_for_all]

    supervise(children, opts)
  end
end
