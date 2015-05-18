defmodule SpawnBasic do
  def greet do
    receive do
      {sender, msg} -> send sender, {:ok, "Hello, #{msg}"}
    end
  end
end

# Client

pid = spawn(SpawnBasic, :greet, [])
send pid, {self, "World!"}

receive do
  {:ok, msg} -> IO.puts msg
end
