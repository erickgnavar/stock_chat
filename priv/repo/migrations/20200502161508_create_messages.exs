defmodule StockChat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :string, null: false
      add :user_id, references(:users, on_delete: :nothing, null: false)

      timestamps()
    end

    create index(:messages, [:user_id])
  end
end
