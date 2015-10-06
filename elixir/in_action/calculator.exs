defmodule Calculator do
  def start do
    spawn(fn -> loop(0) end)
  end

  def add(calculator_pid, value), do: send(calculator_pid, {:add, value})
  def sub(calculator_pid, value), do: send(calculator_pid, {:sub, value})
  def mul(calculator_pid, value), do: send(calculator_pid, {:mul, value})
  def div(calculator_pid, value), do: send(calculator_pid, {:div, value})

  def value(calculator_pid) do
    send(calculator_pid, {:value, self})

    receive do
      {:value, value} -> value
    end
  end

  defp loop(current_value) do
    new_value = receive do
      {:value, caller} ->
        send(caller, {:value, current_value})
        current_value

      {:add, value} -> current_value + value
      {:sub, value} -> current_value - value
      {:mul, value} -> current_value * value
      {:div, value} -> current_value / value

      invalid_request ->
        IO.puts "invalid request #{inspect invalid_request}"
        current_value
    end

    loop(new_value)
  end
end

calculator_pid = Calculator.start
Calculator.value(calculator_pid) |> IO.inspect

Calculator.add(calculator_pid, 10)
Calculator.sub(calculator_pid, 5)
Calculator.mul(calculator_pid, 3)
Calculator.div(calculator_pid, 5)

Calculator.value(calculator_pid) |> IO.inspect
