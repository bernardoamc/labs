defmodule FileStats do
  def line_lengths!(path) do
    File.stream!(path)
    |> Stream.with_index
    |> Stream.map(fn({line, index}) -> {String.length(String.replace(line, "\n", "")), index} end)
    |> Enum.each(fn({len, index}) -> IO.puts "#{index} -> #{len}" end)
  end

  def longest_line!(path) do
    File.stream!(path)
    |> Stream.map(&{String.length(&1), &1})
    |> Enum.reduce({0, ""}, fn({len, line}, {max_len, max_line}) -> if len > max_len, do: {len, line}, else: {max_len, max_line} end)
    |> IO.inspect
  end

  def words_per_line!(path) do
    File.stream!(path)
    |> Stream.with_index
    |> Stream.map(fn({line, index}) -> {length(String.split(line)), index} end)
    |> Enum.each(fn({words, index}) -> IO.puts "#{index} -> #{words}" end)
  end
end

FileStats.line_lengths!("./lines.txt")
IO.puts "---------------------------------------------"
FileStats.longest_line!("./lines.txt")
IO.puts "---------------------------------------------"
FileStats.words_per_line!("./lines.txt")
