defmodule ExChangeRate.Commands do
  @moduledoc """
  Command functions
  """

  import Ecto.Query

  alias Ecto.Changeset

  alias ExChangeRate.Models.ExchangeRateRequest
  alias ExChangeRate.Repo
  alias ExChangeRate.Utils.Currency
  alias ExChangeRate.Workers.ExchangeRateRequestsWorker

  alias ExChangeRateWeb.Params.CreateParams

  @spec create(CreateParams.t()) :: :ok
  def create(%CreateParams{} = params) do
    params
    |> insert_pending_exchange_rate()
    |> insert_exchange_rate_worker()

    :ok
  end

  def update(%{id: id, rate: rate, to_value: to_value, status: :completed}) do
    now = NaiveDateTime.utc_now()

    Repo.transaction(fn ->
      ExchangeRateRequest
      |> where(id: ^id)
      |> update(
        set: [
          status: :completed,
          rate: ^rate,
          to_value: ^to_value,
          completed_at: ^now,
          updated_at: ^now
        ]
      )
      |> Repo.update_all([])
      |> case do
        {1, _} ->
          :ok

        _ ->
          Repo.rollback("record not found")
      end
    end)
  end

  def update(%{id: id, failure_reason: reason, status: :failed}) do
    now = NaiveDateTime.utc_now()
    reason = inspect(reason)

    Repo.transaction(fn ->
      ExchangeRateRequest
      |> where(id: ^id)
      |> update(
        set: [
          status: :failed,
          failure_reason: ^reason,
          failed_at: ^now,
          updated_at: ^now
        ]
      )
      |> Repo.update_all([])
      |> case do
        {1, _} ->
          :ok

        _ ->
          Repo.rollback("record not found")
      end
    end)
  end

  defp insert_pending_exchange_rate(%CreateParams{from: from} = params) do
    params
    |> Map.from_struct()
    |> Map.update!(:from_value, &Currency.new(&1, from))
    |> then(fn params_map ->
      %ExchangeRateRequest{}
      |> ExchangeRateRequest.changeset(params_map)
      |> Changeset.apply_changes()
      |> Repo.insert!()
    end)
  end

  defp insert_exchange_rate_worker(%ExchangeRateRequest{
         id: id,
         from: from,
         to: to,
         from_value: from_value
       }) do
    value = Currency.get_value(from_value)

    %{exchange_rate_request_id: id, from: from, to: to, from_value: value}
    |> ExchangeRateRequestsWorker.new()
    |> Oban.insert!()
  end
end
