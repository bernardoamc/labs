defmodule Telnet.Client do
  def receive({socket, packet}) do
    IO.inspect packet, label: "Packet received"
    :timer.sleep 5000
    :gen_tcp.send socket,"Command received \n"
  end
end
