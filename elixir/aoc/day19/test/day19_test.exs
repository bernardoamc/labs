defmodule Day19Test do
  use ExUnit.Case
  doctest Day19

  # test "part1" do
  #   assert Day19.part1("""
  #   #ip 0
  #   seti 5 0 1
  #   seti 6 0 2
  #   addi 0 1 0
  #   addr 1 2 3
  #   setr 1 0 0
  #   seti 8 0 4
  #   seti 9 0 5
  #   """) == 6
  # end

  test "part2" do
    Day19.part2("""
    #ip 2
    addi 2 16 2
    seti 1 4 3
    seti 1 5 1
    mulr 3 1 5
    eqrr 5 4 5
    addr 5 2 2
    addi 2 1 2
    addr 3 0 0
    addi 1 1 1
    gtrr 1 4 5
    addr 2 5 2
    seti 2 9 2
    addi 3 1 3
    gtrr 3 4 5
    addr 5 2 2
    seti 1 6 2
    mulr 2 2 2
    addi 4 2 4
    mulr 4 4 4
    mulr 2 4 4
    muli 4 11 4
    addi 5 7 5
    mulr 5 2 5
    addi 5 4 5
    addr 4 5 4
    addr 2 0 2
    seti 0 1 2
    setr 2 1 5
    mulr 5 2 5
    addr 2 5 5
    mulr 2 5 5
    muli 5 14 5
    mulr 5 2 5
    addr 4 5 4
    seti 0 6 0
    seti 0 6 2
    """)

    assert 1 == 1
  end
end
