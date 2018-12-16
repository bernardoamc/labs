defmodule Day13 do
  def part1(input) do
    {grid, carts, _} =
      input
      |> String.split("\n", trim: true)
      |> parse_tracks()


    find_collision(grid, carts, nil)
  end

  def part2(input) do
    {grid, carts, _} =
      input
      |> String.split("\n", trim: true)
      |> parse_tracks()


    find_remaining_cart(grid, carts)
  end

  defp find_remaining_cart(grid, carts) do
    {grid, _carts, next_carts} = remaining_tick(grid, carts)

    position_carts_remaining = Map.keys(next_carts)
    if length(position_carts_remaining) > 1 do
      find_remaining_cart(grid, next_carts)
    else
      [position | _] = position_carts_remaining
      position
    end
  end

  defp remaining_tick(grid, carts) do
    ordered_carts_coordinates =
      carts
      |> Map.keys()
      |> fetch_carts_order()

    adjust_state(ordered_carts_coordinates, grid, carts, %{})
  end

  defp adjust_state([{cx, cy} | carts_coordinates], grid, carts, next_carts) do
    {{x_speed, y_speed}, decision} = Map.fetch!(carts, {cx, cy})
    next_coordinate = {cx + x_speed, cy + y_speed}
    cart_state = next_cart_coordinate(grid, next_coordinate, {x_speed, y_speed}, decision)

    if Map.has_key?(carts, next_coordinate) or Map.has_key?(next_carts, next_coordinate) do
      carts = Map.delete(carts, {cx, cy})
      carts = Map.delete(carts, next_coordinate)
      next_carts = Map.delete(next_carts, next_coordinate)
      carts_coordinates = Enum.reject(carts_coordinates, &(&1 == next_coordinate))
      adjust_state(carts_coordinates, grid, carts, next_carts)
    else
      carts = Map.delete(carts, {cx, cy})
      next_carts = Map.put_new(next_carts, next_coordinate, cart_state)
      adjust_state(carts_coordinates, grid, carts, next_carts)
    end
  end

  defp adjust_state([], grid, carts, next_carts) do
    {grid, carts, next_carts}
  end

  defp find_collision(grid, carts, nil) do
    {grid, _carts, next_carts, collision_point} = tick(grid, carts)
    find_collision(grid, next_carts, collision_point)
  end

  defp find_collision(_grid, _carts, collision) do
    collision
  end

  defp tick(grid, carts) do
    ordered_carts_coordinates =
      carts
      |> Map.keys()
      |> fetch_carts_order()

    Enum.reduce_while(ordered_carts_coordinates, {grid, carts, %{}, nil}, fn {cx, cy}, {grid, carts, next_carts, collision_point} ->
      {{x_speed, y_speed}, decision} = Map.fetch!(carts, {cx, cy})
      next_coordinate = {cx + x_speed, cy + y_speed}
      cart_state = next_cart_coordinate(grid, next_coordinate, {x_speed, y_speed}, decision)

      if Map.has_key?(carts, next_coordinate) or Map.has_key?(next_carts, next_coordinate) do
        {:halt, {grid, carts, next_carts, next_coordinate}}
      else
        carts = Map.delete(carts, {cx, cy})
        next_carts = Map.put_new(next_carts, next_coordinate, cart_state)
        {:cont, {grid, carts, next_carts, collision_point}}
      end
    end)
  end

  defp next_cart_coordinate(grid, cart_coordinate, {x_speed, y_speed}, decision) do
    grid_state = Map.get(grid, cart_coordinate, nil)
    cart_state = next_cart_state(grid_state, {x_speed, y_speed}, decision)
    cart_state
  end

  defp next_cart_state("/", {x_speed, 0}, decision), do: {{0, -x_speed}, decision}
  defp next_cart_state("/", {0, y_speed}, decision), do: {{-y_speed, 0}, decision}
  defp next_cart_state("\\", {x_speed, 0}, decision), do: {{0, x_speed}, decision}
  defp next_cart_state("\\", {0, y_speed}, decision), do: {{y_speed, 0}, decision}
  defp next_cart_state("+", {x_speed, 0}, :left), do: {{0, -x_speed}, :straight}
  defp next_cart_state("+", {x_speed, 0}, :straight), do: {{x_speed, 0}, :right}
  defp next_cart_state("+", {x_speed, 0}, :right), do: {{0, x_speed}, :left}
  defp next_cart_state("+", {0, y_speed}, :left), do: {{y_speed, 0}, :straight}
  defp next_cart_state("+", {0, y_speed}, :straight), do: {{0, y_speed}, :right}
  defp next_cart_state("+", {0, y_speed}, :right), do: {{-y_speed, 0}, :left}
  defp next_cart_state(nil, speed, decision), do: {speed, decision}

  defp fetch_carts_order(carts) do
    Enum.sort(carts, fn {x1, y1}, {x2, y2} ->
      if y1 == y2 do
        x1 < x2
      else
        y1 < y2
      end
    end)
  end

  defp parse_tracks(tracks) do
    Enum.reduce(tracks, {%{}, %{}, 0}, fn track, {grid, carts, y} ->
      {grid, carts, _x, y} =
        track
        |> String.codepoints()
        |> Enum.reduce({grid, carts, 0, y}, fn segment, {grid, carts, x, y} ->
          {grid, carts} = parse_segment(segment, grid, carts, {x, y})
          {grid, carts, x+1, y}
        end)

      {grid, carts, y+1}
    end)
  end

  defp parse_segment("/", grid, carts, coordinate), do: {Map.put_new(grid, coordinate, "/"), carts}
  defp parse_segment("\\", grid, carts, coordinate), do: {Map.put_new(grid, coordinate, "\\"), carts}
  defp parse_segment("+", grid, carts, coordinate), do: {Map.put_new(grid, coordinate, "+"), carts}
  defp parse_segment(">", grid, carts, coordinate), do: {grid, Map.put_new(carts, coordinate, {{1, 0}, :left})}
  defp parse_segment("<", grid, carts, coordinate), do: {grid, Map.put_new(carts, coordinate, {{-1, 0}, :left})}
  defp parse_segment("^", grid, carts, coordinate), do: {grid, Map.put_new(carts, coordinate, {{0, -1}, :left})}
  defp parse_segment("v", grid, carts, coordinate), do: {grid, Map.put_new(carts, coordinate, {{0, 1}, :left})}
  defp parse_segment(_, grid, carts, _), do: {grid, carts}
end
