defmodule WeatherHistory do
  def test_data do
    [
      [1366225622, 26, 15, 0.125],
      [1366225622, 27, 15, 0.45],
      [1366225622, 28, 21, 0.25],
      [1366229222, 26, 19, 0.081],
      [1366229222, 27, 17, 0.468],
      [1366229222, 28, 15, 0.60],
      [1366232822, 26, 22, 0.095],
      [1366232822, 27, 21, 0.05],
      [1366232822, 28, 24, 0.03],
      [1366236422, 26, 17, 0.025]
    ]
  end

  def for_location([], _location), do: []
  def for_location([head = [_, location, _, _] | tail], location), do: [head | for_location(tail, location)]
  def for_location([_ | tail], location), do: for_location(tail, location)
end
