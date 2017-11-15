defmodule Telnet do
  use Application

  def start(_type, _args) do
    ip = Application.get_env :telnet_server, :ip, {127,0,0,1}
    port = Application.get_env :telnet_server, :port, 4040

    Telnet.Supervisor.start_link([ip, port])
  end
end
