defmodule HTTPClientTest do
  def get("http://www.omdbapi.com/?plot=short&r=json&t=Matrix") do
    {:ok, %HTTPoison.Response{body: "{\"Title\":\"The Matrix\"}"}}
  end

  def get("http://www.omdbapi.com/?i=A123&plot=short&r=json") do
    {:ok, %HTTPoison.Response{body: "{\"Title\":\"Inception\"}"}}
  end

  def get(_) do
    {:ok, %HTTPoison.Response{body: "{\"Error\":\"Movie not found!\",\"Response\":\"False\"}"}}
  end
end

defmodule MovieTest do
  use ExUnit.Case

  import OmdbClient.Movie, only: [ fetch: 2 ]

  test "fetch a movie by name and returns a map with its attributes" do
    assert fetch({:film, "Matrix"}, HTTPClientTest) == %{"Title" => "The Matrix"}
  end

  test "fetch a movie by id and returns a map with its attributes" do
    assert fetch({:id, "A123"}, HTTPClientTest) == %{"Title" => "Inception"}
  end

  test "displays an error message if the movie cannot be found" do
    assert fetch({:film, "Not Found"}, HTTPClientTest) == "Movie not found!"
  end
end
