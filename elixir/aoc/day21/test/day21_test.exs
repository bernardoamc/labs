defmodule Day21Test do
  use ExUnit.Case
  doctest Day21

  @tag timeout: :infinity
  test "part2" do
    assert Day21.part2("""
    #ip 5
    seti 123 0 4
    bani 4 456 4
    eqri 4 72 4
    addr 4 5 5
    seti 0 0 5
    seti 0 8 4
    bori 4 65536 3
    seti 707129 0 4
    bani 3 255 2
    addr 4 2 4
    bani 4 16777215 4
    muli 4 65899 4
    bani 4 16777215 4
    gtir 256 3 2
    addr 2 5 5
    addi 5 1 5
    seti 27 6 5
    seti 0 7 2
    addi 2 1 1
    muli 1 256 1
    gtrr 1 3 1
    addr 1 5 5
    addi 5 1 5
    seti 25 2 5
    addi 2 1 2
    seti 17 1 5
    setr 2 4 3
    seti 7 4 5
    eqrr 4 0 2
    addr 2 5 5
    seti 5 2 5
    """) == [12502875]
  end
end
