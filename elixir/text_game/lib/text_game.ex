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
    rooms_ast = rooms(config[:rooms])

    quote do
      unquote(rooms_ast)

      def start() do
        TextGame.game_presentation(unquote(name), unquote(config[:description]))
        apply(__MODULE__, unquote(config[:start]), [])
      end
    end
  end

  def game_presentation(name, description) do
    IO.puts "\n" <> String.duplicate("#", 80)
    IO.puts name
    IO.puts description
    IO.puts String.duplicate("#", 80) <> "\n"
  end

  def rooms(rooms_config) do
    for {name, config} <- rooms_config do
      room(name, config)
    end
  end

  def room(name, config) do
    room_description = "\n" <> config[:description]

    quote do
      def unquote(name)() do
        IO.puts unquote(room_description)
        TextGame.render_room(unquote(name), unquote(config), __MODULE__)
      end
    end
  end

  def render_room(name, config, module) do
    possible_actions = possible_actions(config)
    player_action = player_action(possible_actions)

    unless Enum.member?(possible_actions, player_action) do
      IO.puts "\nInvalid option!"
    end

    apply(module, player_movement(config, player_action, name), [])
  end

  def possible_actions(room_config) do
    room_config
      |> Keyword.get(:actions)
      |> Keyword.keys
  end

  def player_action(possible_actions) do
    possible_actions
      |> TextGame.humanize_room_actions
      |> TextGame.fetch_player_input
  end

  def player_movement(room_config, player_action, default_action) do
    room_config
      |> Keyword.get(:actions)
      |> Keyword.get(player_action, default_action)
  end

  def humanize_room_actions(actions) do
    Enum.map(actions, fn action ->
      action |> Atom.to_string |> String.capitalize
    end)
    |> Enum.join(" / ")
  end

  def fetch_player_input(possible_actions) do
    IO.puts "Actions: #{possible_actions}"

    "-> "
    |> IO.gets
    |> String.strip
    |> String.downcase
    |> String.to_atom
  end
end
