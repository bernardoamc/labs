USAGE
====

**Server to process todo lists.**

## Example

{:ok, cache} = Todo.Cache.start

bobs_list = Todo.Cache.server_process(cache, "bobs_list")
Todo.Server.add_entry(bobs_list, %{date: {2013, 12, 19}, title: "Dentist"})

Todo.Server.entries(bobs_list, {2013, 12, 19})
