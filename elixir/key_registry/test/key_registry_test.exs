defmodule KeyRegistryTest do
  use ExUnit.Case
  doctest KeyRegistry

  test "greets the world" do
    assert KeyRegistry.hello() == :world
  end
end
