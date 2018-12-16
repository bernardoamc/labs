defmodule Day2Test do
  use ExUnit.Case
  doctest Day2

  test "compute_characters" do
    assert Day2.compute_characters("aabbcd") == %{97 => 2, 98 => 2, 99 => 1, 100 => 1}
  end

  test "find_occurrences" do
    assert Day2.find_occurrences(%{97 => 1, 98 => 1}) == {0, 0}
    assert Day2.find_occurrences(%{97 => 2, 98 => 2}) == {1, 0}
    assert Day2.find_occurrences(%{97 => 3, 98 => 3}) == {0, 1}
    assert Day2.find_occurrences(%{97 => 2, 98 => 3}) == {1, 1}
  end

  test "part1" do
    assert Day2.part1("""
    abcdef
    bababc
    abbcde
    abcccd
    aabcdd
    abcdee
    ababab
    """) == 12
  end

  test "part2" do
    assert Day2.part2("""
    abcde
    fghij
    klmno
    pqrst
    fguij
    axcye
    wvxyz
    """) == "fgij"
  end
end
