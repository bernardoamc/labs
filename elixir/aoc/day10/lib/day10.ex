defmodule Day10 do
  def part1(input) do
    input
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line/1)
      |> compute_message()
      |> display_sky()
      |> IO.puts()
  end

  def part2(input) do
    {stars, bounding_box, seconds} =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line/1)
      |> compute_message()

    display_sky({stars, bounding_box, seconds})
      |> IO.puts

    seconds
  end

  defp parse_line(line) do
    %{"vx" => vx, "vy" => vy, "x" => x, "y" => y} =
      Regex.named_captures(
        ~r/position=<\s*(?<x>\-?\d+),\s*(?<y>\-?\d+)> velocity=<\s*(?<vx>\-?\d+),\s*(?<vy>\-?\d+)>/,
        line
      )

    %{x: String.to_integer(x), y: String.to_integer(y), vx: String.to_integer(vx), vy: String.to_integer(vy)}
  end

  def compute_message(stars) do
    bounding_box = compute_bounding_box(stars)
    compute_movement(stars, bounding_box, 0, false)
  end

  def compute_movement(stars, bounding_box, seconds, false) do
    next_state = Enum.map(stars, fn star ->
      %{star | x: star.x + star.vx, y: star.y + star.vy}
    end)

    new_bounding_box = compute_bounding_box(next_state)

    if area_of(new_bounding_box) > area_of(bounding_box) do
      compute_movement(stars, bounding_box, seconds, true)
    else
      compute_movement(next_state, new_bounding_box, seconds + 1, false)
    end
  end

  def compute_movement(stars, bounding_box, seconds, true) do
    {stars, bounding_box, seconds}
  end

  def compute_bounding_box(stars) do
    {low_x, high_x} = stars |> Enum.map(fn star -> star.x end) |> Enum.min_max
    {low_y, high_y} = stars |> Enum.map(fn star -> star.y end) |> Enum.min_max
    {low_x..high_x, low_y..high_y}
  end

  defp display_sky({stars, {x_range, y_range}, _seconds}) do
    by_position = Enum.group_by(stars, fn star -> {star.x, star.y} end)

    Enum.reduce(y_range, "", fn y, grid ->
      grid = grid <> "\n"
      Enum.reduce(x_range, grid, fn x, grid ->
        point = {x, y}

        grid <>
          case by_position[point] do
            stars when is_list(stars) ->
              "#"
            nil ->
              "."
          end
      end)
    end)
  end

  defp area_of({xs, ys}) do
    (xs.last - xs.first) * (ys.last - ys.first)
  end
end
