defmodule Day15Test do
  use ExUnit.Case
  doctest Day15

  test "part1" do
    assert Day15.part1("""
    #######
    #.G...#
    #...EG#
    #.#.#G#
    #..G#E#
    #.....#
    #######
    """, %{elf: 3, goblin: 3}) == 27730
  end
end
