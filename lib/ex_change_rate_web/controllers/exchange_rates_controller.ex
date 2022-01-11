defmodule ExChangeRateWeb.ExchangeRatesController do
  use ExChangeRateWeb, :controller
  use ExChangeRateWeb.Specs.ExchangeRateControllerSpecs

  alias ExChangeRate.Commands
  alias ExChangeRate.Queries

  alias ExChangeRateWeb.ErrorView
  alias ExChangeRateWeb.ExchangeRatesView
  alias ExChangeRateWeb.Params.CreateParams

  def index(conn, %{"user_id" => user_id}) do
    case Ecto.UUID.cast(user_id) do
      {:ok, _} ->
        exchange_rate_requests = Queries.list_by_user_id(user_id)

        conn
        |> put_status(200)
        |> put_view(ExchangeRatesView)
        |> render("exchange_rates.json", %{exchange_rate_requests: exchange_rate_requests})

      :error ->
        conn
        |> put_status(200)
        |> render(ErrorView, "400.json", message: "user_id must be an UUID")
    end
  end

  def create(conn, params) do
    case CreateParams.changeset(%CreateParams{}, params) do
      %{valid?: true} = changeset ->
        changeset
        |> Ecto.Changeset.apply_changes()
        |> Commands.create()

        send_resp(conn, 202, "")

      changeset ->
        conn
        |> put_status(400)
        |> render(ErrorView, "400.json", changeset: changeset)
    end
  end
end
