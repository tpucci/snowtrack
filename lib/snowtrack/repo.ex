defmodule Snowtrack.Repo do
  use Ecto.Repo,
    otp_app: :snowtrack,
    adapter: Ecto.Adapters.Postgres
end
