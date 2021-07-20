defmodule MP3 do
  @moduledoc """
  Provides MP3 parsing.
  """

  @id3_size_bytes 128

  @doc """
  The last 128 bytes of an MP3 files consists of:
    - "TAG" (3 bytes)
    - Title (30 bytes)
    - Artist (30 bytes)
    - Album (4 bytes)
    - Rest

  Returns the MP3 metadata in the format: "title artist album year"
  """
  def metadata(mp3_filename) do
    metadata = mp3_filename
      |> read
      |> extract_metadata

    <<
      "TAG",
       title :: binary-size(30),
       artist :: binary-size(30),
       album :: binary-size(30),
       year :: binary-size(4),
       _ :: binary
    >> = metadata

    "#{artist} - #{title} (#{album}, #{year})"
  end

  defp read(filename) do
    case File.read(filename) do
      {:ok, mp3} -> mp3
      _ -> :error
    end
  end

  defp extract_metadata(:error), do: raise "Couldn't open filename"
  defp extract_metadata(mp3_binary) when is_binary(mp3_binary) do
    mp3_byte_size = byte_size(mp3_binary) - @id3_size_bytes
    << _ :: binary-size(mp3_byte_size), id3_tag :: binary >> = mp3_binary
    id3_tag
  end
end
