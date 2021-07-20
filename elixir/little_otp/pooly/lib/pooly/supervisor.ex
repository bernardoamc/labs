defmodule Pooly.Supervisor do
  @moduledoc """
    This is the Main Supervisor, its job is to supervise
    its own state (Server) and the PoolsSupervisor.
  """

  use Supervisor

  def start_link(pools_config) do
    Supervisor.start_link(__MODULE__, pools_config, name: __MODULE__)
  end

  def init(pool_config) do
    children = [
      supervisor(Pooly.PoolsSupervisor, []),
      worker(Pooly.Server, [pools_config])
    ]

    opts = [strategy: :one_for_all]

    supervise(children, opts)
  end
end
