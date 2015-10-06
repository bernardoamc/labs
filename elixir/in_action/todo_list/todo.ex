defmodule TodoList do
  defstruct auto_id: 1, entries: HashDict.new

  def new, do: %TodoList{}

  def new(entries \\ []) do
    Enum.reduce(entries, %TodoList{}, fn(entry, todo_list) ->
      add_entry(todo_list, entry)
    end)
  end

  def add_entry(%TodoList{entries: entries, auto_id: auto_id} = todo_list, entry) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = HashDict.put(entries, auto_id, entry)

    %TodoList{todo_list | entries: new_entries, auto_id: auto_id + 1}
  end

  def update_entry(%TodoList{entries: entries} = todo_list, entry_id, updater_fun) do
    case entries[entry_id] do
      nil -> todo_list

      old_entry ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry) # Asserting that the function does not change the id.
        new_entries = HashDict.put(entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(%TodoList{entries: entries} = todo_list, entry_id) do
    new_entries = HashDict.delete(entries, entry_id)
    %TodoList{todo_list | entries: new_entries}
  end

  def entries(%TodoList{entries: entries} = todo_list, date) do
    entries
    |> Stream.filter(fn({_, entry}) -> entry.date == date end)
    |> Enum.map(fn({_, entry}) -> entry end)
  end
end

defmodule TodoList.CsvImporter do
  def import(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&normalize_entry/1)
    |> TodoList.new
  end

  def normalize_entry(string_entry) do
    [date, title] = String.split(string_entry, ",")

    [year, month, day] = String.split(date, "/")
    |> Enum.map(&String.to_integer(&1))

    %{date: {year, month, day}, title: title}
  end
end
