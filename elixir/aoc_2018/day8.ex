defmodule Day8 do
  def part1(input) do
    input
      |> String.trim()
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
      |> compute_node()
      |> sum_metadata()
  end

  def part2(input) do
    {tree, _rest} = input
      |> String.trim()
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
      |> compute_node()

    sum_indexed_metadata(tree)
  end

  defp compute_node([amount_children, amount_metadata | rest]) do
    {children, rest} = compute_children(amount_children, rest, [])
    {metadata, rest} = Enum.split(rest, amount_metadata)
    {{children, metadata}, rest}
  end

  defp compute_children(0, rest, children) do
    {Enum.reverse(children), rest}
  end

  defp compute_children(amount_children, rest, children) do
    {node, rest} = compute_node(rest)
    compute_children(amount_children - 1, rest, [node | children])
  end

  defp sum_metadata({tree, _rest}) do
    sum_metadata(tree, 0)
  end

  defp sum_metadata({children, metadata}, metadata_count) do
    children_metadata_sum = Enum.reduce(children, 0, fn child, count ->
      sum_metadata(child, count)
    end)

    Enum.sum(metadata) + children_metadata_sum + metadata_count
  end

  # Data structure:
  # {
  #   {
  #     [
  #       {
  #         [],
  #         [1, 2, 3]
  #       },
  #       {
  #         [
  #           {[], 1}
  #         ],
  #         [2]
  #       }
  #     ],
  #     [1, 1, 2]
  #   },
  #   []
  # }

  defp sum_indexed_metadata({[], metadata}) do
    Enum.sum(metadata)
  end

  defp sum_indexed_metadata({children, metadata}) do
    children_sum = Enum.map(children, fn child ->
      sum_indexed_metadata(child)
    end)

    Enum.reduce(metadata, 0, fn metadata_index, acc ->
      Enum.at(children_sum, metadata_index - 1, 0) + acc
    end)
  end
end
