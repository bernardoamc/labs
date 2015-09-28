defmodule Messages do
  def message do
    receive do
      {sender, msg} ->
        send sender, {:ok, msg}
        message
    end
  end
end

first_pid  = spawn(Messages, :message, [])
second_pid = spawn(Messages, :message, [])

send first_pid,  {self, "first"}
send second_pid, {self, "second"}

receive do
  {:ok, msg} -> IO.puts msg
end

receive do
  {:ok, msg} -> IO.puts msg
end
