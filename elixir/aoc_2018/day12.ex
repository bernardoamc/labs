defmodule Day12 do
  @times_same_pattern_appeared 10

  def answer(patterns_input, state_input, generations_count) do
    state =
      state_input
      |> parse_state()

    rules =
      patterns_input
      |> String.split("\n", trim: true)
      |> parse_patterns()

    {_state, _cache, count} = generations(state, rules, generations_count, %{}, 0)
    count
  end

  def generations(state, rules, amount_of_generations, cache, last_count) do
    Enum.reduce_while(1..amount_of_generations, {state, cache, last_count}, fn iteration, {state, cache, last_count} ->
      state = state |> compute_next_state()
      generation = next_generation(state.plants, rules, [])
      new_state = %{state | plants: generation, shift: state.shift - 2}

      # We need to find a pattern between POT sums.
      # We won't find a cycle because the pots are ever shifting or increasing.
      {_index, current_count} = count_plants(new_state.plants, new_state.shift)
      difference_count = current_count - last_count
      amount_of_times_seen = Map.get(cache, difference_count, 1)

      if amount_of_times_seen > 10 do
          final_count = (amount_of_generations - iteration) * difference_count + current_count
          {:halt, {generation, cache, final_count}}
      else
        cache = Map.update(cache, difference_count, 1, &(&1 + 1))
        {:cont, {%{state | plants: generation, shift: state.shift - 2}, cache, current_count}}
      end
    end)
  end

  def next_generation([p1, p2, p3, p4, p5 | rest], rules, next_plants) do
    pattern = to_string([p1, p2, p3, p4, p5])
    next_plant = Map.get(rules, pattern, ".")
    next_generation([p2, p3, p4, p5 | rest], rules, [next_plant | next_plants])
  end

  def next_generation(_plants, _rules, next_plants) do
    next_plants |> Enum.reverse()
  end

  def compute_next_state(state) do
    {left_padded_plants, extra_shift} = pad_plants(state.plants)
    {left_right_padded_plants, _} = pad_plants(Enum.reverse(left_padded_plants))

    %{state | plants: Enum.reverse(left_right_padded_plants), shift: state.shift + extra_shift}
  end

  defp pad_plants(["#" | _] = plants), do: {[".", ".", ".", "." | plants], 4}
  defp pad_plants([".", "#" | _] = plants), do: {[".", ".", "." | plants], 3}
  defp pad_plants([".", ".", "#" | _] = plants), do: {[".", "." | plants], 2}
  defp pad_plants([".", ".", ".", "#" | _] = plants), do: {["." | plants], 1}
  defp pad_plants(plants), do: {plants, 0}

  defp count_plants(plants, shift) do
    Enum.reduce(plants, {-shift, 0}, fn plant, {index, acc} ->
      if plant == "#" do
        {index + 1, acc + index}
      else
        {index + 1, acc}
      end
    end)
  end

  defp parse_state("initial state: " <> state) do
    %{plants: String.codepoints(state), shift: 0}
  end

  defp parse_patterns(patterns) do
    Enum.reduce(patterns, %{}, fn pattern, acc ->
      [condition, result] = String.split(pattern, " => ")
      Map.put(acc, condition, result)
    end)
  end
end
