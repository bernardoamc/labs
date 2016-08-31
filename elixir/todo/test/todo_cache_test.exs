defmodule TodoCacheTest do
  use ExUnit.Case, async: false

  setup do
    :meck.new(Todo.Database, [:no_link])
    :meck.expect(Todo.Database, :start, fn(_) -> nil end)
    :meck.expect(Todo.Database, :get, fn(_) -> nil end)
    :meck.expect(Todo.Database, :store, fn(_, _) -> :ok end)
    on_exit(fn -> :meck.unload(Todo.Database) end)
  end

  test "server_process" do
    {:ok, cache} = Todo.Cache.start
    bobs_list = Todo.Cache.server_process(cache, "bobs_list")
    alices_list = Todo.Cache.server_process(cache, "alices_list")

    assert(bobs_list != alices_list)
    assert(bobs_list == Todo.Cache.server_process(cache, "bobs_list"))

    send(cache, :stop)
  end
end
