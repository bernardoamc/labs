defmodule Day1Test do
  use ExUnit.Case
  doctest Day1

  test "compute_frequency" do
    assert Day1.compute_frequency("""
           +1
           -2
           +3
           +1
           """) == 3
  end

  test "find_seen_frequency" do
    assert Day1.find_seen_frequency("""
           +1
           -2
           +3
           +1
           """) == 2
  end
end
