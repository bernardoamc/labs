defmodule Assertion do
  defmacro __using__(options \\ []) do
    quote do
      import unquote(__MODULE__)

      def run do
        IO.puts "Running the tests..."
      end
    end
  end
end

defmodule MathTest do
  use Assertion
end
