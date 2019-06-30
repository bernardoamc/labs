defmodule Day23 do
  def part1(input) do
    nanobots =
      input
      |> String.split("\n", trim: true)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&parse_entry/1)

    [mx, my, mz, mr] = nanobots |> Enum.max_by(fn [_, _, _, r] -> r end)

    nanobots
      |> Enum.filter(fn [x, y, z, _] -> manhattan_distance({x, y, z}, {mx, my, mz}) <= mr end)
      |> Enum.count()
  end

  def part2(input) do
    nanobots =
      input
      |> String.split("\n", trim: true)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&parse_entry/1)

    cube = Enum.reduce(nanobots, {{0, 0}, {0, 0}, {0, 0}}, fn nanobot, min_max ->
      define_cube(nanobot, min_max)
    end)

    # 1..25
    #   |> Enum.map(fn x -> random_point(cube) end)
    #   |> Enum.map(fn x -> local_max(nanobots, x, {0,0}, 10) end)

    local_max(nanobots, {17304966, 29121001, 52139624}, {0,0}, 10)
  end

  defp local_max(_, _, metadata, 0), do: metadata

  defp local_max(nanobots, {x, y, z}=point, {distance, in_range}, count) do
    steps = 1
    amount = 1000

    {new_point, distance, in_range} =
      Enum.reduce(-steps..steps, {point, distance, in_range}, fn step_x, {point, distance, in_range} ->
        Enum.reduce(-steps..steps, {point, distance, in_range}, fn step_y, {point, distance, in_range} ->
          Enum.reduce(-steps..steps, {point, distance, in_range}, fn step_z, {point, distance, in_range} ->
            Enum.reduce(1..amount, {point, distance, in_range}, fn step_amout, {point, distance, in_range} ->
              jump = :math.pow(step_amout, 2)

              new_point = {x+(step_x * jump), y+(step_y * jump), z+(step_z * jump)}
              new_range = in_range(nanobots, point)
              new_distance = abs(x+step_x) + abs(y+step_y) + abs(z+step_z)

              if new_range > in_range do
                {new_point, new_distance, new_range}
              else
                if in_range > new_range do
                  {new_point, distance, in_range}
                else
                  if new_distance < distance, do: {new_point, new_distance, new_range}, else: {new_point, distance, in_range}
                end
              end
            end)
          end)
        end)
      end)

    IO.inspect({new_point, distance, in_range})
    local_max(nanobots, new_point, {distance, in_range}, count-1)
  end

  defp random_point({{min_x, max_x}, {min_y, max_y}, {min_z, max_z}}) do
    random_x = Enum.random(min_x..max_x)
    random_y = Enum.random(min_y..max_y)
    random_z = Enum.random(min_z..max_z)

    {random_x, random_y, random_z}
  end

  defp in_range(nanobots, {x, y, z}) do
    nanobots
      |> Enum.filter(fn [nx, ny, nz, nr] -> manhattan_distance({nx, ny, nz}, {x, y, z}) <= nr end)
      |> Enum.count()
  end

  defp parse_entry(line) do
    %{"x" => x, "y" => y, "z" => z, "r" => r} =
      Regex.named_captures(
        ~r/pos=<\s*(?<x>\-?\d+),\s*(?<y>\-?\d+),\s*(?<z>\-?\d+)>, r=\s*(?<r>\-?\d+)/,
        line
      )

    [String.to_integer(x), String.to_integer(y), String.to_integer(z), String.to_integer(r)]
  end

  defp manhattan_distance({x1, y1, z1}, {x2, y2, z2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end

  defp define_cube([x, y, z, _r], {{min_x, max_x}, {min_y, max_y}, {min_z, max_z}}) do
    min_x = if x < min_x, do: x, else: min_x
    max_x = if x > max_x, do: x, else: max_x
    min_y = if x < min_y, do: y, else: min_y
    max_y = if x > max_y, do: y, else: max_y
    min_z = if x < min_z, do: z, else: min_z
    max_z = if x > max_z, do: z, else: max_z

    {{min_x, max_x}, {min_y, max_y}, {min_z, max_z}}
  end
end
