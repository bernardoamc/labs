defmodule Day16 do
  import NimbleParsec

  #1 @ 1,3: 4x4
  defparsec :parse_registers,
    choice([
      ignore(string("Before: [")),
      ignore(string("After:  ["))
    ])
    |> integer(min: 1)
    |> ignore(string(", "))
    |> integer(min: 1)
    |> ignore(string(", "))
    |> integer(min: 1)
    |> ignore(string(", "))
    |> integer(min: 1)
    |> ignore(string("]"))

  defparsec :parse_instruction,
    integer(min: 1)
    |> ignore(string(" "))
    |> integer(min: 1)
    |> ignore(string(" "))
    |> integer(min: 1)
    |> ignore(string(" "))
    |> integer(min: 1)

  def part1(filename) do
    entries =
      filename
      |> File.read!
      |> String.split("\n", strip: true)
      |> Stream.reject(&(&1 == ""))
      |> Stream.chunk_every(3)
      |> Enum.map(&parse_entry/1)

      entries
        |> match_instructions
        |> Enum.filter(&(length(elem(&1, 1)) >= 3))
        |> Enum.count
  end

  def part2(reverse_filename, execute_filename) do
    opcodes =
      reverse_filename
      |> File.read!
      |> String.split("\n", strip: true)
      |> Stream.reject(&(&1 == ""))
      |> Stream.chunk_every(3)
      |> Enum.map(&parse_entry/1)
      |> match_instructions
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
      |> Enum.map(fn {opcode, all_instructions} -> {opcode, all_instructions |> Stream.concat() |> Enum.uniq()} end)
      |> Enum.sort(fn {_op1, ins1}, {_op2, ins2} -> length(ins1) <= length(ins2) end)
      |> opcodes(%{})
      |> Enum.reduce(%{}, fn {instruction, opcode}, opcodes_map -> Map.put(opcodes_map, opcode, instruction) end)

    instructions =
      execute_filename
      |> File.read!
      |> String.split("\n", strip: true)
      |> Enum.map(fn instruction ->
        {:ok, [_, _, _, _] = instruction, _, _, _, _} = parse_instruction(instruction)
        instruction
      end)

    execute(instructions, opcodes, %{0 => 0, 1 => 0, 2 => 0, 3 => 0})
  end

  defp execute([], _opcodes, state), do: state

  defp execute([input | remaining], opcodes, state) do
    [opcode, _a, _b, _c] = input
    operation = Map.fetch!(opcodes, opcode)
    instruction = Map.fetch!(instructions(), operation)
    new_state = instruction.(input, state)

    execute(remaining, opcodes, new_state)
  end

  defp opcodes([], opcodes), do: opcodes

  defp opcodes([{current_opcode, instructions} | remaining_traces], opcodes) do
    instructions
    |> Stream.reject(&Map.has_key?(opcodes, &1))
    |> Stream.map(&opcodes(remaining_traces, Map.put(opcodes, &1, current_opcode)))
    |> Enum.find(&(not is_nil(&1)))
  end

  defp match_instructions(entries) do
    Enum.reduce(entries, [], fn entry, possibilities ->
      options = Enum.filter(all_instructions(), fn instruction ->
        instruction = Map.fetch!(instructions(), instruction)
        next_state = execute_instruction(instruction, entry.instruction, entry.previous)

        Map.values(next_state) == entry.next
      end)

      [opcode, _, _, _] = entry.instruction
      [{opcode, options} | possibilities]
    end)
  end

  defp parse_entry([previous, instruction, next]) do
    {:ok, [_, _, _, _] = previous_state, _, _, _, _} = parse_registers(previous)
    {:ok, [_, _, _, _] = instruction, _, _, _, _} = parse_instruction(instruction)
    {:ok, [_, _, _, _] = next_state, _, _, _, _} = parse_registers(next)

    %{previous: previous_state, instruction: instruction, next: next_state}
  end

  defp execute_instruction(instruction, input, [r0, r1, r2, r3]) do
    state = %{0 => r0, 1 => r1, 2 => r2, 3 => r3}
    instruction.(input, state)
  end

  defp all_instructions(), do: Map.keys(instructions())

  defp instructions() do
    %{
      addr: fn([_, a, b, c], state) -> Map.put(state, c, Map.fetch!(state, a) + Map.fetch!(state, b)) end,
      addi: fn([_, a, b, c], state) -> Map.put(state, c, Map.fetch!(state, a) + b) end,
      mulr: fn([_, a, b, c], state) -> Map.put(state, c, Map.fetch!(state, a) * Map.fetch!(state, b)) end,
      muli: fn([_, a, b, c], state) -> Map.put(state, c, Map.fetch!(state, a) * b) end,
      banr: fn([_, a, b, c], state) -> Map.put(state, c, :erlang.band(Map.fetch!(state, a), Map.fetch!(state, b))) end,
      bani: fn([_, a, b, c], state) -> Map.put(state, c, :erlang.band(Map.fetch!(state, a), b)) end,
      borr: fn([_, a, b, c], state) -> Map.put(state, c, :erlang.bor(Map.fetch!(state, a), Map.fetch!(state, b))) end,
      bori: fn([_, a, b, c], state) -> Map.put(state, c, :erlang.bor(Map.fetch!(state, a), b)) end,
      setr: fn([_, a, _, c], state) -> Map.put(state, c, Map.fetch!(state, a)) end,
      seti: fn([_, a, _, c], state) -> Map.put(state, c, a) end,
      gtir: fn([_, a, b, c], state) -> Map.put(state, c, (if a > Map.fetch!(state,b), do: 1, else: 0)) end,
      gtri: fn([_, a, b, c], state) -> Map.put(state, c, (if Map.fetch!(state,a) > b, do: 1, else: 0)) end,
      gtrr: fn([_, a, b, c], state) -> Map.put(state, c, (if Map.fetch!(state,a) > Map.fetch!(state,b), do: 1, else: 0)) end,
      eqir: fn([_, a, b, c], state) -> Map.put(state, c, (if a == Map.fetch!(state,b), do: 1, else: 0)) end,
      eqri: fn([_, a, b, c], state) -> Map.put(state, c, (if Map.fetch!(state,a) == b, do: 1, else: 0)) end,
      eqrr: fn([_, a, b, c], state) -> Map.put(state, c, (if Map.fetch!(state,a) == Map.fetch!(state,b), do: 1, else: 0)) end,
    }
  end
end
