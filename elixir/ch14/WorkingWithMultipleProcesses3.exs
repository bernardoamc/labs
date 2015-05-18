defmodule Multiple do
  import :timer, only: [sleep: 1]

  def callMe do
    receive do
      {sender, msg} -> send sender, {:ok, "Done #{msg}!"}
    end
  end

  def run do
    pid = spawn_link(Multiple, :callMe, [])
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
