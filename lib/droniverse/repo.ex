defmodule Droniverse.Repo do
  use Ecto.Repo,
    otp_app: :droniverse,
    adapter: Ecto.Adapters.Postgres
end
