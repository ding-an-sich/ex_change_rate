defmodule ExChangeRate.Factory do
  use ExMachina.Ecto, repo: ExChangeRate.Repo

  alias ExChangeRateWeb.Params.CreateParams

  def create_params_factory do
    currencies = ["BRL", "USD", "EUR", "JPY"]
    from = Enum.random(currencies)
    to = Enum.random(currencies -- [from])

    %CreateParams{
      user_id: Ecto.UUID.generate(),
      from: from,
      to: to,
      from_value: :rand.uniform(500_000)
    }
  end
end
