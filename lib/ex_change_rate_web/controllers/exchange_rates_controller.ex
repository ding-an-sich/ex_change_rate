defmodule ExChangeRateWeb.ExchangeRatesController do
  use ExChangeRateWeb, :controller

  alias ExChangeRate.Commands
  alias ExChangeRate.Queries

  alias ExChangeRateWeb.Params.CreateParams
  alias ExChangeRateWeb.ExchangeRatesView

  def index(conn, params) do
    with user_id when is_binary(user_id) <- Map.get(params, "user_id", nil),
         {:ok, _} <- Ecto.UUID.cast(user_id),
         exchange_rate_requests <- Queries.list_by_user_id(user_id) do
      conn
      |> put_status(200)
      |> put_view(ExchangeRatesView)
      |> render("exchange_rates.json", %{exchange_rate_requests: exchange_rate_requests})
    end
  end

  def create(conn, params) do
    case CreateParams.changeset(%CreateParams{}, params) do
      %{valid?: true} = changeset ->
        changeset
        |> Ecto.Changeset.apply_changes()
        |> Commands.create()

        send_resp(conn, 202, "")

      _ ->
        raise "todo"
    end
  end
end
