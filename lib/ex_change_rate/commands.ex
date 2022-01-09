defmodule ExChangeRate.Commands do
  alias ExChangeRate.Models.ExchangeRateRequest
  alias ExChangeRateWeb.Params.CreateParams

  alias Ecto.Changeset
  alias ExChangeRate.Repo

  @spec create(CreateParams.t()) :: :ok
  def create(%CreateParams{} = params) do
    params
    |> insert_pending_exchange_rate()
    |> insert_get_exchange_rate_job()

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

  defp insert_get_exchange_rate_job(%ExchangeRateRequest{
         id: id,
         from: from,
         to: to,
         to_value: value
       }) do
    :ok
  end
end
