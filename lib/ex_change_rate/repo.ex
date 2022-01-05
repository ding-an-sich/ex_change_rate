defmodule ExChangeRate.Repo do
  use Ecto.Repo,
    otp_app: :ex_change_rate,
    adapter: Ecto.Adapters.Postgres
end
