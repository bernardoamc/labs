defmodule EctoTest.App do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    tree = [worker(EctoTest.Repo, [])]
    opts = [name: EctoTest.Sup, strategy: :one_for_one]
    Supervisor.start_link(tree, opts)
  end
end
