defmodule ExChangeRate.Repo.Migrations.AddMoneyColumnsToExchangeRateRequests do
  use Ecto.Migration

  def up do
    alter table("exchange_rate_requests") do
      add :from_value, :money_currency, null: false
      add :to_value, :money_currency
    end
  end

  def down do
    alter table("exchange_rate_requests") do
      remove :from_value, :money_currency, null: false
      remove :to_value, :money_currency
    end
  end
end
