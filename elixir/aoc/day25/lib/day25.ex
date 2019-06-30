defmodule Day25 do
  @distance 3

  def part1(input) do
      input
      |> String.split("\n", trim: true)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&parse_coordinates/1)
      |> build_digraph()
      |> :digraph_utils.components()
      |> length()
  end

  defp build_digraph(coordinates) do
    Enum.reduce(coordinates, :digraph.new(), fn coordinate, digraph ->
      :digraph.add_vertex(digraph, coordinate)
      digraph
    end)
    |> add_edges(coordinates)
  end

  defp add_edges(digraph, []), do: digraph

  defp add_edges(digraph, [coordinate | coordinates]) do
    Enum.reduce(:digraph.vertices(digraph), digraph, fn vertex, digraph ->
      if manhattan_distance(vertex, coordinate) <= @distance do
        :digraph.add_edge(digraph, vertex, coordinate)
      end

      digraph
    end)

    add_edges(digraph, coordinates)
  end

  defp manhattan_distance({x1, y1, z1, w1}, {x2, y2, z2, w2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2) + abs(w1 - w2)
  end

  defp parse_coordinates(line) do
    %{"x" => x, "y" => y, "z" => z, "w" => w} =
      Regex.named_captures(
        ~r/\s*(?<x>\-?\d+),\s*(?<y>\-?\d+),\s*(?<z>\-?\d+),\s*(?<w>\-?\d+)/,
        line
      )

    {String.to_integer(x), String.to_integer(y), String.to_integer(z), String.to_integer(w)}
  end
end
