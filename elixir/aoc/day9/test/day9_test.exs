defmodule Day9Test do
  use ExUnit.Case
  doctest Day9

  test "part1" do
    assert Day9.part1(9, 25) == 32
    assert Day9.part1(10, 1618) == 8317
    assert Day9.part1(13, 7999) == 146373
    assert Day9.part1(17, 1104) == 2764
    assert Day9.part1(21, 6111) == 54718
    assert Day9.part1(30, 5807) == 37305
  end
end
