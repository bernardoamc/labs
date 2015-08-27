defmodule OmdbClient.Movie do
  @moduledoc """
  Fetch movies from Omdb API by name or id.
  """

  @omdb_url Application.get_env(:omdb, :omdb_url)

  def fetch({:film, name}, http_client) do
    build_url(%{ "t" => name, "plot" => "short", "r" => "json"})
    |> http_client.get
    |> handle_response
  end

  def fetch({:id, id}, http_client) do
    build_url(%{ "i" => id, "plot" => "short", "r" => "json"})
    |> http_client.get
    |> handle_response
  end

  defp build_url(query) do
    [@omdb_url, URI.encode_query(query)]
    |> Enum.join("?")
  end

  defp handle_response({:ok, %HTTPoison.Response{body: body}}) do
    Poison.decode!(body)
    |> parse_response
  end

  defp handle_response({:error, _}) do
    IO.puts "Erro na requisição."
    System.halt(0)
  end

  defp parse_response(%{"Error" => error, "Response" => "False"}) do
    error
  end

  defp parse_response(response), do: response
end
