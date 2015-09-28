defmodule Multiple do
  import :timer, only: [sleep: 1]

  def callMe do
    receive do
      {sender, msg} ->
        send sender, { :ok, "#{msg} ack" }
        raise "Kboom"
    end
  end

  def run do
    {pid, _} = spawn_monitor(Multiple, :callMe, [])
    send pid, {self, "Bla"}

    sleep 500
    Multiple.receive_messages
  end

  def receive_messages do
    receive do
      {:ok, msg} -> IO.puts msg
    end

    receive_messages
  end
end

Multiple.run
