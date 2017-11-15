defmodule TelnetTest do
  use ExUnit.Case
  doctest Telnet

  test "greets the world" do
    assert Telnet.hello() == :world
  end
end
