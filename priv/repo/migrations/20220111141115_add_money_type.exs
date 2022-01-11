defmodule ExChangeRate.Repo.Migrations.AddMoneyType do
  use Ecto.Migration

  def up do
    execute """
    CREATE TYPE public.money_currency AS (amount integer, currency char(3))
    """
  end

  def down do
    execute """
    DROP TYPE public.money_currency
    """
  end
end
