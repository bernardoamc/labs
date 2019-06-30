defmodule Day16Test do
  use ExUnit.Case
  doctest Day16

  test "part1" do
    assert Day16.part1("part1.txt") == 517
  end

  test "part2" do
    assert Day16.part2("part1.txt", "part2.txt") == %{0 => 667, 1 => 667, 2 => 3, 3 => 2}
  end
end
