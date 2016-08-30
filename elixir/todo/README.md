# Todo

**A single mix project to manage todo-lists.**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `todo` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:todo, "~> 0.1.0"}]
    end
    ```

  2. Ensure `todo` is started before your application:

    ```elixir
    def application do
      [applications: [:todo]]
    end
    ```

## Usage

```elixir
{:ok, cache} = Todo.Cache.start
Todo.Cache.server_process(cache, "Bob's list")
Todo.Cache.server_process(cache, "Alice's list")

bobs_list = Todo.Cache.server_process(cache, "Bob's list")

Todo.Server.add_entry(bobs_list, %{date: {2013, 12, 19}, title: "Dentist"})
Todo.Server.entries(bobs_list, {2013, 12, 19})

Todo.Cache.server_process(cache, "Alice's list")
|> Todo.Server.entries({2013, 12, 19})
```
