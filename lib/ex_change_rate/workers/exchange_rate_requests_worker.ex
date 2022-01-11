defmodule ExChangeRate.Workers.ExchangeRateRequestsWorker do
  use Oban.Worker,
    queue: :requests,
    max_attempts: 3

  alias ExChangeRate.Clients.ExchangeratesAPI
  alias ExChangeRate.Commands

  require Logger

  @impl Oban.Worker
  def perform(%{
        attempt: attempt,
        max_attempts: max_attempts,
        args: %{
          "exchange_rate_request_id" => id,
          "from" => from,
          "to" => to,
          "from_value" => from_value
        }
      }) do
    with {:ok, %{^from => from_rate, ^to => to_rate}} <-
           ExchangeratesAPI.call(%{from: from, to: to}),
         rate <- get_exchange_rate(from_rate, to_rate),
         to_value <- get_to_value(from_value, rate),
         {:ok, :ok} <-
           Commands.update(%{id: id, rate: rate, to_value: to_value, status: :completed}) do
      :ok
    else
      {:error, "record not found" = reason} ->
        Logger.critical("Failed to process exchange rate request due to record not found")

        {:discard, reason}

      {:error, reason} = error ->
        Logger.error("Failed to process exchange rate request due to error: #{inspect(reason)}")

        if attempt < max_attempts do
          error
        else
          Commands.update(%{id: id, failure_reason: reason, status: :failed})
          error
        end
    end
  end

  defp get_exchange_rate(from_rate, to_rate) do
    from_rate = Decimal.from_float(from_rate)
    to_rate = Decimal.from_float(to_rate)

    to_rate
    |> Decimal.div(from_rate)
    |> Decimal.round(4)
  end

  defp get_to_value(from_value, rate) do
    from_value
    |> Decimal.new()
    |> Decimal.mult(rate)
    |> Decimal.to_integer()
  end
end
