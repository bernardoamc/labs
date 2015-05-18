defmodule EctoTest.Models.Product do
  use Ecto.Model

  @primary_key {:product_id, :integer, read_after_writes: true}

  schema "products" do
    field :name, :string
    field :price, :decimal

    timestamps
  end
end
