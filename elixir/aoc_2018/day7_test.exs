defmodule Day7Test do
  use ExUnit.Case
  doctest Day7

  test "part1" do
    assert Day7.part1("""
    Step C must be finished before step A can begin.
    Step C must be finished before step F can begin.
    Step A must be finished before step B can begin.
    Step A must be finished before step D can begin.
    Step B must be finished before step E can begin.
    Step D must be finished before step E can begin.
    Step F must be finished before step E can begin.
    """) == "CABDFE"
  end

  test "part2" do
    assert Day7.part2("""
    Step C must be finished before step A can begin.
    Step C must be finished before step F can begin.
    Step A must be finished before step B can begin.
    Step A must be finished before step D can begin.
    Step B must be finished before step E can begin.
    Step D must be finished before step E can begin.
    Step F must be finished before step E can begin.
    """, workers: 2, step_duration: 0) == 15
  end
end
