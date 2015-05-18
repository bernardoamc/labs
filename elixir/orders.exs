defmodule Wow do
  def orders do
    file = File.open!("orders.txt")
    headers = IO.read(file, :line) |> as_row |> Enum.map(&String.to_atom/1)
    file |> IO.stream(:line) |> Enum.map(&(get_order(&1, headers)))
  end

  defp get_order(order , headers) do
    Enum.zip(headers, create_row(order |> as_row))
  end

  defp create_row([id, << ?: :: utf8, ship_to :: binary >>, amount]) do
    [String.to_integer(id), String.to_atom(ship_to), String.to_float(amount)]
  end

  def as_row(line) do
    line |> String.rstrip(?\n) |> String.split(",")
  end

  def taxes do
    [ NC: 0.075, TX: 0.08 ]
  end

  def add_total(order = [id: _, ship_to: state, net_amount: net], taxes) do
    tax_rate = Keyword.get(taxes, state, 0)
    Keyword.put(order, :total_amount, (net + (net * tax_rate)))
  end

  def process(orders, taxes) do
    orders |> Enum.map(&(add_total(&1, taxes)))
  end
end

IO.inspect Wow.process(Wow.orders, Wow.taxes)
