defmodule Loop do
  defmacro while(expression, do: block) do
    quote do
      try do
        for _ <- Stream.cycle([:ok]) do
          if unquote(expression) do
            unquote(block)
          else
            break
          end
        end
      catch
        :break -> :ok
      end
    end
  end

  def break, do: throw :break
end

defmodule Test do
  import Loop

  run_loop = fn ->

    pid = spawn(fn -> :timer.sleep(4000) end)

    while Process.alive?(pid) do
      IO.puts "#{inspect :erlang.time} Stayin'alive!"
      :timer.sleep 1000
    end
  end

  run_loop.()
end
