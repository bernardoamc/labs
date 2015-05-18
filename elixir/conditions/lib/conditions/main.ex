defmodule Conditions.Main do
  @moduledoc """
  Fetch the current weather history from
  http://w1.weather.gov/xml/current_obs/KDTO.xml
  parses it and generates a nice formatted table
  with the information.
  """

  require Logger

  def main(argv) do
    Conditions.Weather.fetch
    |> parse_response
    |> Conditions.TableFormatter.format
  end

  @doc """
  Parse the XML document returned by Conditions.Weather.fetch.

  Return an array of tuples of `{ attribute, value }`.
  """
  def parse_response({:ok, body}) do
    Logger.info "Starting to parse data."

    {root, _ } = :xmerl_scan.string(String.to_char_list(body))

    # Returns an array like:
    # [
    #   {:xmlText, [temp_c: 30, current_observation: 2], 1, [], '15.6', :text},
    #   ...
    # ]
    :xmerl_xpath.string('/current_observation/*/text()', root)
    |> Enum.filter_map &has_not_url_or_image_in_attribute_name?/1, &format_xml_attribute/1
  end

  @doc """
  Abort the system if Conditions.Weather.fetch fails to fetch the XML.

  Return to the shell the status code 1.
  """
  def parse_response({:error, reason}) do
    Logger.info "Error fetching url data, reason: #{reason}"
    System.halt(1)
  end

  @doc """
  Check if the attribute does not have the `url` or `image` substring.

  Return a boolean.
  """
  def has_not_url_or_image_in_attribute_name?({_, [{attribute, _}, _], _, _, _, _}) do
    !Regex.match?(~r/url|image/i, Kernel.to_string(attribute))
  end

  @doc """
  Format a XML node into a Tuple.

  Return a Tuple of {attribute, value}.
  """
  def format_xml_attribute({_, [{attribute, _}, _], _, _, value, _}) do
    {Kernel.to_string(attribute), Kernel.to_string(value)}
  end
end
