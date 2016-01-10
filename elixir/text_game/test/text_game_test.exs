defmodule TextGameTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest TextGame

  defmodule Game do
    use TextGame

    game "What I am doing here?",
      description: "A game about figuring things out.",
      start: :bedroom,
      rooms: [
        bedroom: [
          description: """
                       Bedroom description.
                       """,
          actions: [
            left: :living_room,
            right: :bath_room
          ]
        ],

        living_room: [
          description: """
                       Living Room description.
                       """,
          actions: [
            right: :bedroom
          ]
        ],

        bath_room: [
          description: """
                       Bathroom description.
                       """,
          actions: [
            left: :bedroom
          ]
        ]
      ]
  end

  test "creates a 'start' method" do
    game_methods =
      Game.__info__(:functions)
      |> Keyword.keys

    assert Enum.member?(game_methods, :start)
  end

  test "creates one method per room" do
    game_methods =
      Game.__info__(:functions)
      |> Keyword.keys

    [:bedroom, :living_room, :bath_room]
      |> Enum.each(fn room ->
        assert Enum.member?(game_methods, room)
      end)
  end
end
