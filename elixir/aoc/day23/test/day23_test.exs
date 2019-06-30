defmodule Day23Test do
  use ExUnit.Case
  doctest Day23

  # test "part1" do
  #   assert Day23.part1("""
  #   pos=<0,0,0>, r=4
  #   pos=<1,0,0>, r=1
  #   pos=<4,0,0>, r=3
  #   pos=<0,2,0>, r=1
  #   pos=<0,5,0>, r=3
  #   pos=<0,0,3>, r=1
  #   pos=<1,1,1>, r=1
  #   pos=<1,1,2>, r=1
  #   pos=<1,3,1>, r=1
  #   """) == 7
  # end

  # test "part2" do
  #   assert Day23.part2("""
  #   pos=<0,0,0>, r=4
  #   pos=<1,0,0>, r=1
  #   pos=<4,0,0>, r=3
  #   pos=<0,2,0>, r=1
  #   pos=<0,5,0>, r=3
  #   pos=<0,0,3>, r=1
  #   pos=<1,1,1>, r=1
  #   pos=<1,1,2>, r=1
  #   pos=<1,3,1>, r=1
  #   """) == [12, 12, 12]
  # end

  @tag timeout: :infinity
  test "part2" do
    assert Day23.part2(File.read!("input.txt")) == [12, 12, 12]
  end
end
