defmodule Telnet.Command do
  def parse(client_socket, command) do
    Telnet.ClientsRegistry.broadcast(client_socket, command)
    :gen_tcp.send client_socket, "Command acknowledged\n"
  end
end
