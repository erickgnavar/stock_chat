defmodule StockChat.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :image, :string
    field :name, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :username, :image])
    |> validate_required([:name, :username, :image])
  end
end
