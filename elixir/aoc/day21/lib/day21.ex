defmodule Day21 do

  def part1(input) do
    input
      |> String.split("\n", strip: true)
      |> Stream.reject(&(&1 == ""))
      |> Enum.map(&parse_instruction/1)
      |> new_machine()
      |> Stream.iterate(&exec_next_instruction/1)
      |> Enum.find(fn machine -> machine.ip == 28 end)
      |> get_reg(0)
  end
  def part2(input) do
    input
      |> String.split("\n", strip: true)
      |> Stream.reject(&(&1 == ""))
      |> Enum.map(&parse_instruction/1)
      |> new_machine()
      |> all_28_till_cycle()
      |> Enum.take(1)
  end

  defp all_28_till_cycle(machine) do
    machine
      |> Stream.iterate(&exec_next_instruction/1)
      |> Stream.filter(fn machine -> machine.ip == 28 end)
      |> Stream.transform(MapSet.new(), fn machine, seen_states ->
        # if we're on the same instruction with the same registers, the device will cycle, so we stop here
        if MapSet.member?(seen_states, machine.registers) do
          {:halt, seen_states}
        else
          {[machine], MapSet.put(seen_states, machine.registers)}
        end
      end)
      |> Stream.map(&get_reg(&1, 4))
      |> Stream.uniq()
      |> Enum.reverse()
  end

  defp parse_instruction(<<"#ip ", register>>), do: {:bind_ip, register - ?0}

  defp parse_instruction(<<op::binary-size(4), " ", args::binary>>) do
    args = String.replace(args, ~r/#.*/, "")
    {String.to_existing_atom(op), args |> String.split() |> Enum.map(&String.to_integer/1)}
  end

  defp new_machine([{:bind_ip, register} | instructions]) do
    %{
      ip: 0,
      ip_register: register,
      instructions: List.to_tuple(instructions),
      registers: 0..5 |> Stream.map(&{&1, 0}) |> Map.new()
    }
  end

  # 17 seti 0 7 2           set 0 to reg2  [X, 0, 0, 65536, 8765139, 17]
  # 18 addi 2 1 1           add reg2 and 1  [X, 1, 0, 65536, 8765139, 18]
  # 19 muli 1 256 1         reg1 * 256 [X, 256, 0, 65536, 8765139, 19]
  # 20 gtrr 1 3 1           reg1 > reg3? [X, 0, 0, 65536, 8765139, 20]
  # 21 addr 1 5 5           reg1 + reg5  [X, 0, 0, 65536, 8765139, 21]
  # 22 addi 5 1 5           reg5 + 1  [X, 0, 0, 65536, 8765139, 23]
  # 23 seti 25 2 5          SKIP
  # 24 addi 2 1 2           reg2 + 1  [X, 0, 1, 65536, 8765139, 24]
  # 25 seti 17 1 5          17 into r5  [X, 0, 1, 65536, 8765139, 17]
  # 26 setr 2 4 3           SKIP

  # Which translated becomes this inner loop:
  # while reg1 < reg3 do
  #   reg1 = reg2 + 1
  #   reg1 = reg1 * 256
  # end
  #
  # Meaning:
  #   - reg1 ends with value 1
  #   - reg2 ends with value div(f, 256)
  defp exec_next_instruction(%{ip: 18} = machine) do
    d = get_reg(machine, 1)
    f = get_reg(machine, 3)
    d = if d > f, do: d, else: div(f, 256)

    new_machine =
      machine
      |> put_reg(1, 1)
      |> put_reg(2, d)

    %{new_machine | ip: 26}
  end

  defp exec_next_instruction(machine) do
    next_machine =
      machine
      |> put_reg(machine.ip_register, machine.ip)
      |> exec(elem(machine.instructions, machine.ip))
      |> update_ip()

    next_machine
  end

  defp update_ip(machine), do: %{machine | ip: get_reg(machine, machine.ip_register) + 1}

  defp get_reg(machine, pos), do: Map.fetch!(machine.registers, pos)
  defp put_reg(machine, pos, value), do: %{machine | registers: Map.put(machine.registers, pos, value)}

  defp exec(machine, {instruction, [a, b, c]}), do: Map.fetch!(instructions(), instruction).(machine, a, b, c)

  defp instructions() do
    %{
      addr: &put_reg(&1, &4, get_reg(&1, &2) + get_reg(&1, &3)),
      addi: &put_reg(&1, &4, get_reg(&1, &2) + &3),
      mulr: &put_reg(&1, &4, get_reg(&1, &2) * get_reg(&1, &3)),
      muli: &put_reg(&1, &4, get_reg(&1, &2) * &3),
      banr: &put_reg(&1, &4, :erlang.band(get_reg(&1, &2), get_reg(&1, &3))),
      bani: &put_reg(&1, &4, :erlang.band(get_reg(&1, &2), &3)),
      borr: &put_reg(&1, &4, :erlang.bor(get_reg(&1, &2), get_reg(&1, &3))),
      bori: &put_reg(&1, &4, :erlang.bor(get_reg(&1, &2), &3)),
      gtir: &put_reg(&1, &4, if(&2 > get_reg(&1, &3), do: 1, else: 0)),
      gtri: &put_reg(&1, &4, if(get_reg(&1, &2) > &3, do: 1, else: 0)),
      gtrr: &put_reg(&1, &4, if(get_reg(&1, &2) > get_reg(&1, &3), do: 1, else: 0)),
      eqir: &put_reg(&1, &4, if(&2 == get_reg(&1, &3), do: 1, else: 0)),
      eqri: &put_reg(&1, &4, if(get_reg(&1, &2) == &3, do: 1, else: 0)),
      eqrr: &put_reg(&1, &4, if(get_reg(&1, &2) == get_reg(&1, &3), do: 1, else: 0)),
      setr: fn machine, reg_a, _b, reg_c -> put_reg(machine, reg_c, get_reg(machine, reg_a)) end,
      seti: fn machine, val, _b, reg_c -> put_reg(machine, reg_c, val) end
    }
  end
end
