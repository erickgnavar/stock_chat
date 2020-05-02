defmodule StockChat.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION citext"

    create table(:users) do
      add :name, :string
      add :username, :citext
      add :image, :string

      timestamps()
    end
  end

  def down do
    drop table(:users)

    execute "DROP EXTENSION citext"
  end
end
