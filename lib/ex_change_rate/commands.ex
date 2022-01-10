defmodule ExChangeRate.Commands do
  alias ExChangeRate.Models.ExchangeRateRequest
  alias ExChangeRateWeb.Params.CreateParams

  alias Ecto.Changeset

  alias ExChangeRate.Repo
  alias ExChangeRate.Workers.ExchangeRateRequestsWorker

  @spec create(CreateParams.t()) :: :ok
  def create(%CreateParams{} = params) do
    params
    |> insert_pending_exchange_rate()
    |> insert_exchange_rate_worker()

    :ok
  end

  defp insert_pending_exchange_rate(%CreateParams{} = params) do
    params
    |> Map.from_struct()
    |> then(fn params_map ->
      ExchangeRateRequest.changeset(
        %ExchangeRateRequest{},
        params_map
      )
      |> Changeset.apply_changes()
      |> Repo.insert!()
    end)
  end

  defp insert_exchange_rate_worker(%ExchangeRateRequest{
         id: id,
         from: from,
         to: to,
         from_value: value
       }) do
    %{exchange_rate_request_id: id, from: from, to: to, value: value}
    |> ExchangeRateRequestsWorker.new()
    |> Oban.insert!()
  end
end
