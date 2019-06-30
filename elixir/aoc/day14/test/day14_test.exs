defmodule Day14Test do
  use ExUnit.Case
  doctest Day14

  test "part1" do
    assert Day14.part1([3,7], 9) == [5,1,5,8,9,1,6,7,7,9]
    assert Day14.part1([3,7], 5) == [0,1,2,4,5,1,5,8,9,1]
    assert Day14.part1([3,7], 18) == [9,2,5,1,0,7,1,0,8,5]
    assert Day14.part1([3,7], 2018) == [5,9,4,1,4,2,9,8,8,2]
  end

  test "part2" do
    assert Day14.part2([3,7], [5,1,5,8,9]) == 9
    assert Day14.part2([3,7], [0,1,2,4,5]) == 5
    assert Day14.part2([3,7], [9,2,5,1,0]) == 18
    assert Day14.part2([3,7], [5,9,4,1,4]) == 2018
  end
end
