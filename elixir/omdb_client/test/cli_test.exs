defmodule CliTest do
  use ExUnit.Case

  import OmdbClient.CLI, only: [ parse_args: 1 ]

  test "returns :help when parsing -h and --help options" do
    assert parse_args(["-h"]) == :help
    assert parse_args(["--help"]) == :help
  end

  test "returns { :film, <name> } when parsing -f <name> and --film <name> options" do
    assert parse_args(["-f", "Matrix"]) == { :film, "Matrix" }
    assert parse_args(["--film", "Matrix"]) == { :film, "Matrix" }
  end

  test "returns { :id, <id> } when parsing -i <id> and --id <id> options" do
    assert parse_args(["-i", "A123"]) == { :id, "A123" }
    assert parse_args(["--id", "A123"]) == { :id, "A123" }
  end

  test "returns :help when parsing any options besides --film or --id" do
    assert parse_args(["--something", "random"]) == :help
  end
end
