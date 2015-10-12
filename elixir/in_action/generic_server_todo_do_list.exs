defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init
      loop(callback_module, initial_state)
    end)
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self})

    receive do
      {:response, response} -> response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} = callback_module.handle_call(request, current_state)
        send(caller, {:response, response})
        loop(callback_module, new_state)

      {:cast, request} ->
        new_state = callback_module.handle_cast(request, current_state)
        loop(callback_module, new_state)
    end
  end
end

defmodule TodoList do
  defstruct auto_id: 1, entries: HashDict.new

  def init do
    %TodoList{}
  end

  def start do
    ServerProcess.start(TodoList)
  end

  def add_entry(pid, entry) do
    ServerProcess.cast(pid, {:add_entry, entry})
  end

  def update_entry(pid, entry_id, updater_fun) do
    ServerProcess.cast(pid, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(pid, entry_id) do
    ServerProcess.cast(pid, {:delete_entry, entry_id})
  end

  def entries(pid, date) do
    ServerProcess.call(pid, {:entries, date})
  end

  def handle_cast({:add_entry, entry}, %TodoList{entries: entries, auto_id: auto_id} = todo_list) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = HashDict.put(entries, auto_id, entry)

    %TodoList{todo_list | entries: new_entries, auto_id: auto_id + 1}
  end

  def handle_cast({:update_entry, entry_id, updater_fun}, %TodoList{entries: entries} = todo_list) do
    case entries[entry_id] do
      nil -> todo_list

      old_entry ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry) # Asserting that the function does not change the id.
        new_entries = HashDict.put(entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def handle_cast({:delete_entry, entry_id}, %TodoList{entries: entries} = todo_list) do
    new_entries = HashDict.delete(entries, entry_id)
    %TodoList{todo_list | entries: new_entries}
  end

  def handle_call({:entries, date}, %TodoList{entries: entries} = todo_list) do
    list = entries
      |> Stream.filter(fn({_, entry}) -> entry.date == date end)
      |> Enum.map(fn({_, entry}) -> entry end)

    {list, todo_list}
  end
end

pid = TodoList.start
TodoList.add_entry(pid, %{date: {2013, 12, 19}, title: "Dentist"})
TodoList.add_entry(pid, %{date: {2013, 12, 20}, title: "Shopping"})
TodoList.add_entry(pid, %{date: {2013, 12, 19}, title: "Movies"})
TodoList.entries(pid, {2013, 12, 19}) |> IO.inspect

TodoList.delete_entry(pid, 3)
TodoList.entries(pid, {2013, 12, 19}) |> IO.inspect

update_title = fn(entry) -> Map.put(entry, :title, "Foca") end
TodoList.update_entry(pid, 2, update_title)
TodoList.entries(pid, {2013, 12, 20}) |> IO.inspect
