defmodule MultiDict do
  def new, do: HashDict.new

  def add(dict, key, value) do
    HashDict.update(
      dict,
      key,
      [value],
      &[value | &1]
    )
  end

  def get(dict, key) do
    HashDict.get(dict, key, [])
  end
end
