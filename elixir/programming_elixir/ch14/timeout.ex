defmodule SpawnTimeout do
  def greet do
    receive do
      {sender, msg} -> send sender, {:ok, "Hello, #{msg}"}
    end
  end
end

# Client

pid = spawn(SpawnTimeout, :greet, [])
send pid, {self, "World!"}

receive do
  {:ok, msg} -> IO.puts msg
end

send pid, {self, "Timeout!"}

receive do
  {:ok, msg} -> IO.puts msg
  after 500 -> IO.puts "We suffered a timeout after 500 miliseconds, noooo!"
end
