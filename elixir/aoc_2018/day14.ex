defmodule Day14 do
  def part1(recipes, num_recipes) do
    recipe_stream(recipes, {0, 1})
      |> Stream.drop(num_recipes)
      |> Stream.take(10)
      |> Enum.to_list

  end

  def part2(recipes, original_pattern) do
    original_pattern_length = length(original_pattern)

    Enum.reduce_while(recipe_stream(recipes, {0, 1}), {original_pattern, 0,}, fn recipe, {remaining, index} ->
      index = index + 1
      new_remaining = match_pattern(remaining, original_pattern, recipe)

      new_remaining =
        if length(new_remaining) > length(remaining) do
          match_pattern(new_remaining, original_pattern, recipe)
        else
          new_remaining
        end

      if Enum.empty?(new_remaining) do
        {:halt, index - original_pattern_length}
      else
        {:cont, {new_remaining, index}}
      end
    end)
  end

  def match_pattern([current_recipe | remaining], _original_pattern, current_recipe) do
    remaining
  end

  def match_pattern([_ | _tail], original_pattern, _) do
    original_pattern
  end

  defp recipe_stream([recipe1, recipe2] = recipes, current_chef_positions) do
    recipes_binary = <<recipe1, recipe2>>
    acc = {recipes_binary, current_chef_positions, recipes}
    Stream.unfold(acc, &get_next_recipe/1)
  end

  defp get_next_recipe(acc) do
    case acc do
      {recipes, chef_positions, [h | t]} -> {h, {recipes, chef_positions, t}}
      {recipes, chef_positions, []} ->
        build_more_recipes(recipes, chef_positions)
          |> get_next_recipe()
    end
  end

  defp build_more_recipes(recipes, {chef1_position, chef2_position}) do
    next_recipe = :binary.at(recipes, chef1_position) + :binary.at(recipes, chef2_position)
    new_recipes = Enum.map(Integer.to_charlist(next_recipe), &(&1 - ?0))

    recipes = <<recipes::binary, :erlang.list_to_binary(new_recipes)::binary>>
    recipes_amount = byte_size(recipes)
    chef1_position = rem(chef1_position + 1 + :binary.at(recipes, chef1_position), recipes_amount)
    chef2_position = rem(chef2_position + 1 + :binary.at(recipes, chef2_position), recipes_amount)
    {recipes, {chef1_position, chef2_position}, new_recipes}
  end
end
