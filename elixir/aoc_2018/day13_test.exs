defmodule Day13Test do
  use ExUnit.Case
  doctest Day13

  test "part1" do
    assert Day13.part1(
      File.read!("input_test.txt")
    ) == {7,3}
  end

  test "part2" do
    assert Day13.part2(
      File.read!("input2_test.txt")
    ) == {6,4}
  end
end
