defmodule Day2 do
  def part1(input) do
    {twos, threes} = input
    |> String.split("\n", trim: true)
    |> Enum.reduce({0, 0}, fn line, {two_acc, three_acc} ->
      {two, three} = line |> compute_characters() |> find_occurrences()
      {two + two_acc, three + three_acc}
    end)

    twos * threes
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> find_most_similar
  end

  def find_most_similar([head | tail]) do
    Enum.find_value(tail, &one_letter_difference(head, &1)) || find_most_similar(tail)
  end

  def one_letter_difference(box1, box2) do
    one_letter_difference(box1, box2, [], 0)
  end

  defp one_letter_difference(<<head, tail1::binary>>, <<head, tail2::binary>>, same, difference_count) do
    one_letter_difference(tail1, tail2, [head | same], difference_count)
  end

  defp one_letter_difference(<<_, tail1::binary>>, <<_, tail2::binary>>, same, difference_count) do
    one_letter_difference(tail1, tail2, same, difference_count + 1)
  end

  defp one_letter_difference(<<>>, <<>>, same, 1) do
    same |> Enum.reverse() |> List.to_string()
  end

  defp one_letter_difference(<<>>, <<>>, _, _) do
    nil
  end

  def find_occurrences(char_count) do
    Enum.reduce(char_count, {0, 0}, fn
      {_letter, 2}, {_two, three} -> {1, three}
      {_letter, 3}, {two, _three} -> {two, 1}
      _, occurrences -> occurrences
    end )
  end

  def compute_characters(line) when is_binary(line) do
    line
    |> compute_characters(%{})
  end

  defp compute_characters(<<letter, rest::binary>>, acc) do
    acc = Map.update(acc, letter, 1, &(&1 + 1))
    compute_characters(rest, acc)
  end

  defp compute_characters(<<>>, acc) do
    acc
  end
end
