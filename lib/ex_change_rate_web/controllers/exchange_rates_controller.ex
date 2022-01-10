defmodule ExChangeRateWeb.ExchangeRatesController do
  use ExChangeRateWeb, :controller

  alias ExChangeRate.Commands
  alias ExChangeRateWeb.Params.CreateParams

  def index(conn, params) do
    :ok
  end

  def create(conn, params) do
    case CreateParams.changeset(%CreateParams{}, params) do
      %{valid?: true} = changeset ->
        changeset
        |> Ecto.Changeset.apply_changes()
        |> Commands.create()

        conn
        |> put_status(202)

      _ ->
        raise "todo"
    end
  end
end
