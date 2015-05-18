defmodule EctoTest.Repo.Migrations.AddProductsTable do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :product_id, :serial, primary_key: true
      add :name, :string
      add :price, :decimal

      timestamps
    end
  end
end
