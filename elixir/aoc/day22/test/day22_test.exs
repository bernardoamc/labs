defmodule Day22Test do
  use ExUnit.Case
  doctest Day22

  test "part1" do
    assert Day22.part1(510, {10, 10}) == 114
  end

  test "part1_official" do
    assert Day22.part1(10647, {7, 770}) == 6208
  end

  test "part2" do
    assert Day22.part2(510, {10, 10}) == 45
  end

  test "part2_official" do
    assert Day22.part2(10647, {7, 770}) == 0
  end
end
