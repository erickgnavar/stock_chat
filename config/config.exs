# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :stock_chat,
  ecto_repos: [StockChat.Repo]

# Configures the endpoint
config :stock_chat, StockChatWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "PBgKdGz9VJWFr/Xu3GtvuWLcen4Mgw11sBtcKLeysLZEqS0OInzmoFqkzCTf6axY",
  render_errors: [view: StockChatWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: StockChat.PubSub,
  live_view: [signing_salt: "Iz5nQSZV"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    twitter: {Ueberauth.Strategy.Twitter, []}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
