defmodule ExChangeRate.Workers.ExchangeRateRequestsWorker do
  use Oban.Worker,
    queue: :requests,
    max_attempts: 3,
    unique: [
      fields: [:args],
      period: :infinity
    ]

  @impl Oban.Worker
  def perform(%{
        args: %{
          "exchange_rate_request_id" => id,
          "from" => from,
          "to" => to,
          "value" => value
        }
      }) do
    IO.puts("Implement me")
    :ok
  end
end
