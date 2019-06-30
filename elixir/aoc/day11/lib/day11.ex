  # Suppose your initial table is:
  # 1 1 2 1 3
  # 2 0 3 1 0
  # 1 2 2 0 3
  #
  #
  # The summed table with would become:
  # 01 02 04 05 08
  # 03 02 07 09 12
  # 04 05 12 14 20

  # Now suppose you want to know an area of a square of size 3 with (x,y) being (2,1)
  # {x + 2, y + 2} + {x - 1, y - 1} - {x + 2, y - 1} -  {x - 1, y + 2}
  # {4,3} + {1,0} - {4,0} - {1, 3}
  # 14 - 0 - 0 - 04
  # 10
  #
  # The way it works is just by subtracting the areas from each rectangle to get the square
  # It works because each point represents a rectangle since it sums all the points that occur
  # before them.
defmodule Day11 do
  @grid_size 300

  def part1(serial) do
    serial
      |> summed_area_table()
      |> max_area_total(3)
  end

  def part2(serial) do
    sat = serial
      |> summed_area_table()

    Enum.reduce(1..@grid_size, nil, fn size, max_area ->
      area = max_area_total(sat, size)

      if is_nil(max_area) or elem(area, 1) > elem(max_area, 1) do
        area
      else
        max_area
      end
    end)
  end

  defp summed_area_table(serial) do
    Enum.reduce(1..@grid_size, %{}, fn y, cells ->
      Enum.reduce(1..@grid_size, cells, fn x, cells ->
        cell = {x, y}
        power_level = fuel_cell_power(cell, serial)

        sum =
          power_level +
          Map.get(cells, {x, y - 1}, 0) +
          Map.get(cells, {x - 1, y}, 0) -
          Map.get(cells, {x - 1, y - 1}, 0)

        Map.put(cells, cell, sum)
      end)
    end)
  end

  def max_area_total(summed_area_table, square_size) do
    offset = square_size - 1
    max_range = @grid_size - offset

    Enum.reduce(1..max_range, nil, fn y, max_area ->
      Enum.reduce(1..max_range, max_area, fn x, max_area ->
        area =
          {
            {x, y, square_size},
            Map.fetch!(summed_area_table, {x + offset, y + offset}) +
            Map.get(summed_area_table, {x - 1, y - 1}, 0) -
            Map.get(summed_area_table, {x + offset, y - 1}, 0) -
            Map.get(summed_area_table, {x - 1, y + offset}, 0)
          }

        if is_nil(max_area) or elem(area, 1) > elem(max_area, 1) do
          area
        else
          max_area
        end
      end)
    end)
  end

  defp fuel_cell_power({x,y}, serial) do
    rack_id = x + 10
    power_level = (rack_id * y) + serial
    hundreds_digit(power_level * rack_id) - 5
  end

  defp hundreds_digit(number) do
    rem(div(number, 100), 10)
  end
end
