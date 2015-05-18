defmodule EctoTest.Queries.Products do
  import Ecto.Query

  def search_by_name(name) do
    query = from w in Products,
         where: w.name == ^name,
         select: w.name
    Simple.Repo.all(query)
  end

  def insert(attributes) do
    EctoTest.Repo.insert(attributes)
  end
end
