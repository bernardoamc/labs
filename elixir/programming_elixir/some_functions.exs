# Calling from erlang
IO.puts (:io_lib.format("~.2f~n", [2.0/3.0]) |> hd)

IO.puts System.get_env("HOME")

IO.puts Path.extname("./hello.exs")

IO.puts System.cwd

IO.puts :os.cmd("date")
