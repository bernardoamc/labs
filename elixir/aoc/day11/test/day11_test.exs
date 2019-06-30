defmodule Day11Test do
  use ExUnit.Case
  doctest Day11

  test "part1" do
    assert Day11.part1(18) == {{33, 45, 3}, 29}
  end

  @tag timeout: 300_000
  test "part2" do
    assert Day11.part2(18) == {{90, 269, 16}, 113}
  end
end
