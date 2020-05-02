defmodule StockChat.Repo do
  use Ecto.Repo,
    otp_app: :stock_chat,
    adapter: Ecto.Adapters.Postgres
end
