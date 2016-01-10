defmodule TextGame do
  defmacro __using__(_options) do
    quote do
      Module.register_attribute __MODULE__, :game, persist: false
      import unquote(__MODULE__), only: [game: 2]
       @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    generate(Module.get_attribute(env.module, :game))
  end

  defmacro game(name, config) do
    quote bind_quoted: [name: name, config: config] do
      @game {name, config}
    end
  end

  def generate({name, config} = game) do
    rooms_ast = generate_rooms(config[:rooms])
    start_ast = generate_start(name, config)

    quote do
      unquote(rooms_ast)
      unquote(start_ast)
    end
  end

  def generate_start(name, config) do
    game_presentation_ast = game_presentation(name, config[:description])

    quote do
      def start() do
        unquote(game_presentation_ast)
        apply(__MODULE__, unquote(config[:start]), [])
      end
    end
  end

  def game_presentation(name, description) do
    quote do
      IO.puts "\n" <> String.duplicate("#", 80)
      IO.puts unquote(name)
      IO.puts unquote(description)
      IO.puts String.duplicate("#", 80) <> "\n"
    end
  end

  def generate_room(name, config) do
    room_actions_ast = room_actions(config)
    room_description = "\n" <> config[:description]

    quote do
      def unquote(name)() do
        IO.puts unquote(room_description)
        unquote(room_actions_ast)
      end
    end
  end

  def room_actions(config) do
    possible_actions =
      config
      |> Keyword.get(:actions)
      |> Keyword.keys

    fetch_player_option_ast =
      possible_actions
      |> humanize_room_actions
      |> fetch_player_action

    quote bind_quoted: [possible_actions: possible_actions, fetch_player_option_ast: fetch_player_option_ast, config: config] do
      player_action = fetch_player_option_ast

      if Enum.member?(possible_actions, player_action) do
        go_to =
          config
          |> Keyword.get(:actions)
          |> Keyword.get(player_action)

        apply(__MODULE__, go_to, [])
      else
        IO.puts "\nInvalid option!"
        {current_room, _} = __ENV__.function
        apply(__MODULE__, current_room, [])
      end
    end
  end

  def humanize_room_actions(actions) do
    Enum.map(actions, fn action ->
      action |> Atom.to_string |> String.capitalize
    end)
    |> Enum.join(" / ")
  end

  def fetch_player_action(possible_actions) do
    quote do
      IO.write "Actions: "
      IO.puts unquote(possible_actions)

       "-> "
      |> IO.gets
      |> String.rstrip(?\n)
      |> String.downcase
      |> String.to_atom
    end
  end

  def generate_rooms(rooms) do
    for {name, config} <- rooms do
      generate_room(name, config)
    end
  end
end

defmodule Game do
  use TextGame

  game "What I am doing here?",
    description: "A game about figuring things out.",
    start: :bedroom,
    rooms: [
      bedroom: [
        description: """
                     You wake up in a pretty disorganized room, full of clothes everywhere.
                     It is strange, but you don't remember why you are here.
                     """,
        actions: [
          left: :living_room,
          right: :bath_room
        ]
      ],

      living_room: [
        description: """
                     You are in the Living Room.
                     There is a white carpet in the center of the room with a big red stain, looks like blood.
                     """,
        actions: [
          right: :bedroom
        ]
      ],

      bath_room: [
        description: """
                     You stand in the Bath Room.
                     There is a mirror on the wall and a shower on your left.
                     """,
        actions: [
          left: :bedroom
        ]
      ]
    ]
end
