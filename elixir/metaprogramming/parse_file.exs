defmodule ParseFile do
  # Every time text_file changes, mix will recompile this module automatically.
  @external_resource file_path = Path.join([__DIR__, "text_file"])

  for line <- File.stream!(file_path, [], :line) do
    [method, return] = String.split(line, ";")

    def unquote(String.to_atom(method))(), do: unquote(return)
  end
end
