defmodule Day6 do
  def part1(input) do
    coordinates = input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [x, y] = String.split(line, ", ")
        {String.to_integer(x), String.to_integer(y)}
      end)

    boundaries = coordinates |> get_boundary()
    {points_by_coordinate, coordinate_by_points} = associate_points_with_coordinates(coordinates, boundaries)

    find_finite_coordinates(coordinates, points_by_coordinate, boundaries)
      |> Enum.map(fn coordinate ->
        Map.fetch!(coordinate_by_points, coordinate) |> length()
      end)
      |> Enum.max()
  end

  def part2(input) do
    coordinates = input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [x, y] = String.split(line, ", ")
        {String.to_integer(x), String.to_integer(y)}
      end)

      {x_range, y_range} = coordinates |> get_boundary()

      Enum.reduce(x_range, [], fn x, acc ->
        Enum.reduce(y_range, acc, fn y, acc ->
          [compute_distance(coordinates, {x,y}) | acc]
        end)
      end)
      |> Enum.sum()
  end

  defp compute_distance(coordinates, point) do
    distance = coordinates
      |> Enum.map(&(distance(&1, point)))
      |> Enum.sum()

      if distance < 10_000, do: 1, else: 0
  end

  defp get_boundary(coordinates) do
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(coordinates, &(elem(&1, 0)))
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(coordinates, &(elem(&1, 1)))
    {min_x..max_x, min_y..max_y}
  end

  defp associate_points_with_coordinates(coordinates, {x_range, y_range}) do
    Enum.reduce(x_range, {%{}, %{}}, fn x, {points_by_coordinates, coordinates_by_points} ->
      Enum.reduce(y_range, {points_by_coordinates, coordinates_by_points}, fn y, {points_by_coordinates, coordinates_by_points} ->
        point = {x, y}
        coordinate = associate_point_with_coordinate(coordinates, point)

        {
          Map.put(points_by_coordinates, point, coordinate),
          Map.update(coordinates_by_points, coordinate, [point], &([point | &1]))
        }
      end)
    end)
  end

  defp associate_point_with_coordinate(coordinates, point) do
    coordinates
      |> Enum.map(&({distance(&1, point), &1}))
      |> Enum.sort()
      |> case do
        [{0, coordinate} | _] -> coordinate
        [{distance, _}, {distance, _} | _] -> nil
        [{_, coordinate} | _] -> coordinate
      end
  end

  defp find_finite_coordinates(coordinates, points_by_coordinate, {first_x..last_x, first_y..last_y}) do
    Enum.filter(coordinates, fn {cx, cy} = coordinate ->
      (Map.fetch!(points_by_coordinate, {first_x, cy}) != coordinate) &&
      (Map.fetch!(points_by_coordinate, {last_x, cy}) != coordinate) &&
      (Map.fetch!(points_by_coordinate, {cx, first_y}) != coordinate) &&
      (Map.fetch!(points_by_coordinate, {cx, last_y}) != coordinate)
    end)
  end

  defp distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end
end
