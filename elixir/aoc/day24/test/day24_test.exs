defmodule Day24Test do
  use ExUnit.Case
  doctest Day24

  test "part1" do
    assert Day24.part1("input_test.txt") == 5216
  end

  test "part1 official" do
    assert Day24.part1("input.txt") == 0
  end

  test "part2 official" do
    assert Day24.part2("input.txt") == 0
  end
end
