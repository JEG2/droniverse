defmodule Droniverse.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Droniverse.Repo,
      # Start the Telemetry supervisor
      DroniverseWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Droniverse.PubSub},
      # Start the Endpoint (http/https)
      DroniverseWeb.Endpoint
      # Start a worker by calling: Droniverse.Worker.start_link(arg)
      # {Droniverse.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Droniverse.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DroniverseWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
