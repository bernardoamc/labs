defmodule Conditions.Weather do
  require Logger

  @weather_url Application.get_env(:conditions, :weather_url)

  def fetch do
    Logger.info "Fetching weather history from: #{@weather_url}"

    HTTPoison.get(@weather_url)
    |> handle_response
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    { :ok, body }
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 404}}) do
    { :error, "page not found" }
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    { :error, reason }
  end
end
