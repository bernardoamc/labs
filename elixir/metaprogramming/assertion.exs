defmodule Assertion do
  defmacro __using__(options \\ []) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute __MODULE__, :tests, accumulate: true
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    quote do
      def run, do: Assertion.Test.run(@tests, __MODULE__)
    end
  end

  defmacro test(description, do: test_block) do
    test_func = String.to_atom(description)

    quote do
      @tests {unquote(test_func), unquote(description)}
      def unquote(test_func)(), do: unquote(test_block)
    end
  end

  defmacro assert({operator, _, [lhs, rhs]}) do
    quote bind_quoted: [operator: operator, lhs: lhs, rhs: rhs] do
      Assertion.Test.assert(operator, lhs, rhs)
    end
  end
end

defmodule Assertion.Test do
  def run(tests, module) do
    parent = self()

    {case_pid, case_ref} =
      spawn_monitor(fn ->
        Enum.each tests, &spawn_test(module, &1)
        send parent, {self, :case_finished, tests}

        exit(:shutdown)
      end)

    output =
      receive do
        {^case_pid, :case_finished, tests} ->
          receive do
             {:DOWN, ^case_ref, :process, ^case_pid, _} -> :ok
          end
          tests
        {:DOWN, ^case_ref, :process, ^case_pid, error} ->
          %{error: {:EXIT, tests, error}}
      end

    output
  end

  def spawn_test(module, test) do
    parent = self()

    {test_pid, test_ref} =
      spawn_monitor(fn ->
        run_test(module, test)
        send parent, {self, :test_finished, test}
        exit(:shutdown)
      end)

    test =
      receive do
        {^test_pid, :test_finished, test} ->
          receive do
             {:DOWN, ^test_ref, :process, ^test_pid, _} -> :ok
          end
          test
        {:DOWN, ^test_ref, :process, ^test_pid, error} ->
          %{error: {:EXIT, test, error}}
      end
  end

  def run_test(module, {test_func, description} = test) do
    IO.puts "Executing: #{description}"

    case apply(module, test_func, []) do
      :ok             -> IO.write "."
      {:fail, reason} -> IO.puts """

      ===============================================
      FAILURE: #{description}
      ===============================================
      #{reason}
      """
    end
  end

  def assert(:==, lhs, rhs) when lhs == rhs do
    :ok
  end

  def assert(:==, lhs, rhs) do
    {:fail, """
      Expected:       #{lhs}
      to be equal to: #{rhs}
      """
    }
  end

  def assert(:>, lhs, rhs) when lhs > rhs do
    :ok
  end

  def assert(:>, lhs, rhs) do
    {:fail, """
      Expected:           #{lhs}
      to be greater than: #{rhs}
      """
    }
  end
end

defmodule MathTest do
  use Assertion

  test "integer can be compared with greater than" do
    assert 5 > 10
    assert 10 > 5
  end

  test "integers can be compared for equality" do
    assert 1 == 1
    assert 2 == 3
  end
end
