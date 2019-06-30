defmodule Day6Test do
  use ExUnit.Case
  doctest Day6

  test "part1" do
    assert Day6.part1("""
    1, 1
    1, 6
    8, 3
    3, 4
    5, 5
    8, 9
    """) == 17
  end

  test "part2" do
    assert Day6.part2("""
    1, 1
    1, 6
    8, 3
    3, 4
    5, 5
    8, 9
    """) == 16
  end
end
