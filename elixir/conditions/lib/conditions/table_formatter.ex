defmodule Conditions.TableFormatter do
  def format(columns) do
    {attributes_width, values_width} = widths_of(columns)
    format = format_for([attributes_width, values_width])
    separator = separator_format([attributes_width, values_width], "-")
    print_row({"Attribute", "Value"}, format, separator)
    print_rows(columns, format, separator)
  end

  def widths_of(columns) do
    Enum.reduce columns, {0,0}, fn ({a, v}, {a1, v1}) -> { Enum.max([String.length(a), a1]), Enum.max([String.length(v), v1]) } end
  end

  def format_for(columns_width) do
   Enum.map_join(columns_width, " | ", fn width -> "~-#{width}s" end) <> "~n"
  end

  def print_rows(columns, format, separator) do
    Enum.each columns, &print_row(&1, format, separator)
  end

  def print_row({attribute, value}, format, separator) do
    :io.format(format, [attribute, value])
    IO.puts separator
  end

  def separator_format(columns_width, separator) do
    Enum.map_join(columns_width, "-|-", fn width -> String.duplicate(separator, width) end)
  end
end
