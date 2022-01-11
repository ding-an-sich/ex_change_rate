defmodule ExChangeRateWeb.ExchangeRatesView do
  use ExChangeRateWeb, :view

  alias ExChangeRate.Utils.Currency

  def render("exchange_rates.json", %{exchange_rate_requests: exrrs}) do
    render_many(exrrs, __MODULE__, "exchange_rate.json", as: :exchange_rate_request)
  end

  def render("exchange_rate.json", %{exchange_rate_request: %{status: :pending} = exrr}) do
    %{
      "id" => exrr.id,
      "user_id" => exrr.user_id,
      "status" => Atom.to_string(exrr.status),
      "from" => exrr.from,
      "to" => exrr.to,
      "from_value" => Currency.format_to_string(exrr.from_value),
      "timestamp" => NaiveDateTime.to_iso8601(exrr.inserted_at)
    }
  end

  def render("exchange_rate.json", %{exchange_rate_request: %{status: :completed} = exrr}) do
    %{
      "id" => exrr.id,
      "user_id" => exrr.user_id,
      "status" => Atom.to_string(exrr.status),
      "from" => exrr.from,
      "to" => exrr.to,
      "from_value" => Currency.format_to_string(exrr.from_value),
      "to_value" => Currency.format_to_string(exrr.to_value),
      "rate" => Currency.format_to_string(exrr.rate),
      "timestamp" => NaiveDateTime.to_iso8601(exrr.inserted_at)
    }
  end

  def render("exchange_rate.json", %{exchange_rate_request: %{status: :failed} = exrr}) do
    %{
      "id" => exrr.id,
      "user_id" => exrr.user_id,
      "status" => Atom.to_string(exrr.status),
      "failure_reason" => exrr.failure_reason,
      "from" => exrr.from,
      "to" => exrr.to,
      "from_value" => Currency.format_to_string(exrr.from_value),
      "timestamp" => NaiveDateTime.to_iso8601(exrr.inserted_at)
    }
  end
end
