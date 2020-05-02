defmodule StockChat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      StockChat.Repo,
      # Start the Telemetry supervisor
      StockChatWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: StockChat.PubSub},
      # supervisor to handle task which fetch stocks data from external service
      Supervisor.child_spec({Task.Supervisor, name: StockChat.StockFetcherSupervisor}, []),
      # Start the Endpoint (http/https)
      StockChatWeb.Endpoint
      # Start a worker by calling: StockChat.Worker.start_link(arg)
      # {StockChat.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StockChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    StockChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
