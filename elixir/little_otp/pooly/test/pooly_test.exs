defmodule PoolyTest do
  use ExUnit.Case
  doctest Pooly

  test "greets the world" do
    assert Pooly.hello() == :world
  end
end
