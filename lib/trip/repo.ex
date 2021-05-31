defmodule Trip.Repo do
  use Ecto.Repo,
    otp_app: :trip,
    adapter: Ecto.Adapters.Postgres
end
