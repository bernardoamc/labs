defmodule Day5Test do
  use ExUnit.Case
  doctest Day5

  test "part1" do
    assert Day5.part1("dabAcCaCBAcCcaDA") == 10
  end

  test "part2" do
    assert Day5.part2("dabAcCaCBAcCcaDA") == 4
  end
end
