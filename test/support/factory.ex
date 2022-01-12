defmodule ExChangeRate.Factory do
  @moduledoc """
  Factories for testing
  """
  use ExMachina.Ecto, repo: ExChangeRate.Repo

  alias ExChangeRate.Models.ExchangeRateRequest
  alias ExChangeRate.Utils.Currency
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

  def exchange_rate_request_factory do
    currencies = ["BRL", "USD", "EUR", "JPY"]
    from = Enum.random(currencies)
    to = Enum.random(currencies -- [from])

    %ExchangeRateRequest{
      user_id: Ecto.UUID.generate(),
      from: from,
      to: to,
      status: :pending,
      from_value: Currency.new(:rand.uniform(500_000), from)
    }
  end

  def with_status(
        %ExchangeRateRequest{from_value: from_value, to: to} = model,
        :completed
      ) do
    rate = Decimal.from_float(3.14159)
    from_value = Currency.get_value(from_value)
    to_value = Currency.convert(from_value, rate, to)

    Map.merge(model, %{
      status: :completed,
      rate: rate,
      to_value: to_value,
      completed_at: NaiveDateTime.utc_now()
    })
  end

  def with_status(%ExchangeRateRequest{} = model, :failed) do
    Map.merge(model, %{
      status: :failed,
      failed_at: NaiveDateTime.utc_now(),
      failure_reason: "Have you tried turning it off and on again?"
    })
  end
end
