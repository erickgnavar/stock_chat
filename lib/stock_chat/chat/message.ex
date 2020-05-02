defmodule StockChat.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field(:content, :string)
    belongs_to(:user, StockChat.Auth.User)

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :user_id])
    |> validate_required([:content, :user_id])
  end
end
