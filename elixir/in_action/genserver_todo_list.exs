defmodule TodoList do
  use GenServer

  defstruct auto_id: 1, entries: HashDict.new

  def init(_) do
    {:ok, %TodoList{}}
  end

  def start do
    GenServer.start(TodoList, nil)
  end

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  def update_entry(pid, entry_id, updater_fun) do
    GenServer.cast(pid, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(pid, entry_id) do
    GenServer.cast(pid, {:delete_entry, entry_id})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def handle_cast({:add_entry, entry}, %TodoList{entries: entries, auto_id: auto_id} = todo_list) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = HashDict.put(entries, auto_id, entry)

    {:noreply, %TodoList{todo_list | entries: new_entries, auto_id: auto_id + 1}}
  end

  def handle_cast({:update_entry, entry_id, updater_fun}, %TodoList{entries: entries} = todo_list) do
    case entries[entry_id] do
      nil -> {:noreply, todo_list}

      old_entry ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry) # Asserting that the function does not change the id.
        new_entries = HashDict.put(entries, new_entry.id, new_entry)
        {:noreply, %TodoList{todo_list | entries: new_entries}}
    end
  end

  def handle_cast({:delete_entry, entry_id}, %TodoList{entries: entries} = todo_list) do
    new_entries = HashDict.delete(entries, entry_id)
    {:noreply, %TodoList{todo_list | entries: new_entries}}
  end

  def handle_call({:entries, date}, _, %TodoList{entries: entries} = todo_list) do
    list = entries
      |> Stream.filter(fn({_, entry}) -> entry.date == date end)
      |> Enum.map(fn({_, entry}) -> entry end)

    {:reply, list, todo_list}
  end
end

{:ok, pid} = TodoList.start
TodoList.add_entry(pid, %{date: {2013, 12, 19}, title: "Dentist"})
TodoList.add_entry(pid, %{date: {2013, 12, 20}, title: "Shopping"})
TodoList.add_entry(pid, %{date: {2013, 12, 19}, title: "Movies"})
TodoList.entries(pid, {2013, 12, 19}) |> IO.inspect

TodoList.delete_entry(pid, 3)
TodoList.entries(pid, {2013, 12, 19}) |> IO.inspect

update_title = fn(entry) -> Map.put(entry, :title, "Foca") end
TodoList.update_entry(pid, 2, update_title)
TodoList.entries(pid, {2013, 12, 20}) |> IO.inspect
