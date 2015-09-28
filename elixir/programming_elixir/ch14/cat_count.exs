defmodule CatCount do
  def count(scheduler) do
    send scheduler, { :ready, self }

    receive do
      { :count, file_path, client } ->
        send client, { :answer, cat_count(file_path), self }
        count(scheduler)

      { :shutdown } -> exit(:normal)
    end
  end

  defp cat_count(file_path) do
    parts = File.read!(file_path) |> String.split("cat") |> length

    parts - 1
  end
end

defmodule Scheduler do
  def run(num_processes, module, func, files) do
    (1..num_processes)
    |> Enum.map(fn (_) -> spawn(module, func, [self]) end)
    |> schedule_processes(files, 0)
  end

  defp schedule_processes([], [], count) do
    count
  end

  defp schedule_processes(processes, [], count) do
    receive do
      {:ready, pid} ->
        send pid, {:shutdown}
        schedule_processes(List.delete(processes, pid), [], count)

      {:answer, occurrences, _pid} ->
        schedule_processes(processes, [], count + occurrences)
    end
  end

  defp schedule_processes(processes, files, count) do
    receive do
      {:ready, pid} ->
        [file | rest] = files
        send pid, {:count, file, self}
        schedule_processes(processes, rest, count)

      {:answer, occurrences, _pid} ->
        schedule_processes(processes, files, count + occurrences)
    end
  end
end

dir = "./test_files/"
IO.puts Scheduler.run(10, CatCount, :count, File.ls!(dir) |> Enum.map(fn (file) -> dir <> file end))
