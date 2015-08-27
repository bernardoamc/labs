defmodule OmdbClient.CLI do
  @moduledoc """
  Handle the command line parsing and dispatch params
  to other functions responsible for fetching films.
  """

  def run(argv) do
    parse_args(argv)
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(
      argv,
      switches: [ help: :boolean, film: :string, id: :string ],
      aliases: [ h: :help, f: :film, i: :id ]
    )

    case parse do
      { [ help: true ], _, _ } -> :help
      { [ film: name ], _, _ } -> { :film, name }
      { [ id: id ], _, _ } -> { :id, id }
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    USAGE:
      omdb_client --film <name>
      omdb_client -f <name>
      omdb_client --id <id>
      omdb_client -i <id>
    """

    System.halt(0)
  end

  def process({:film, name}) do
    {:film, name}
    |> OmdbClient.Movie.fetch(HTTPoison)
    |> IO.inspect
  end

  def process({:id, id}) do
    {:id, id}
    |> OmdbClient.Movie.fetch(HTTPoison)
    |> IO.inspect
  end
end
