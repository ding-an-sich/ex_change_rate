defmodule ExChangeRate.Repo.Migrations.CreateExchangeRateRequestsTable do
  use Ecto.Migration

  def up do
    create table("exchange_rate_requests", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, :binary_id, null: false
      add :to, :string, null: false
      add :from, :string, null: false
      add :rate, :decimal
      add :status, :string, default: "pending", null: false
      add :failure_reason, :string
      add :failed_at, :naive_datetime_usec
      add :completed_at, :naive_datetime_usec

      timestamps(type: :naive_datetime_usec)
    end
  end

  def down do
    drop table("exchange_rate_requests")
  end
end
