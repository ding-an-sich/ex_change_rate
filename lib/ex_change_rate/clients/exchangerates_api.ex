defmodule ExChangeRate.Clients.ExchangeratesAPI do
  @moduledoc """
  Client that fetches exchange rate information for a pair of currencies.
  Works in base EUR only.
  """

  use Tesla, only: [:get]

  require Logger

  @base_url "http://api.exchangeratesapi.io/v1/"

  @headers [
    {"Accept", "application/json"},
    {"User-Agent", "ex_change_rate"}
  ]

  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.Headers, @headers
  plug Tesla.Middleware.Query, access_key: fetch_api_key!(), base: "EUR"
  plug Tesla.Middleware.JSON

  @spec call(map()) :: {:ok, map()} | {:error, term()}
  def call(%{from: from, to: to} = currencies_pair) do
    Logger.info("Fetching exchange rate information for #{inspect(currencies_pair)}}")

    "latest"
    |> get(query: [symbols: "#{from}, #{to}"])
    |> handle_response
    |> case do
      {:ok, _rates} = result ->
        Logger.info("Sucessfully fetched exchange rates")

        result

      {:error, reason} = error ->
        Logger.error(
          "Could not fetch currency exchange information because of reason: #{inspect(reason)}"
        )

        error
    end
  end

  defp fetch_api_key! do
    :ex_change_rate
    |> Application.fetch_env!(__MODULE__)
    |> Keyword.fetch!(:api_key)
  end

  defp handle_response({:ok, %{status: status, body: body}})
       when status in 200..299,
       do: parse_body(body)

  defp handle_response({:ok, %{status: status}}),
    do: {:error, "unexpected status, #{inspect(status)}"}

  defp handle_response({:error, _reason} = error),
    do: error

  defp parse_body(%{"success" => true, "rates" => rates}),
    do: {:ok, rates}

  defp parse_body(%{"sucess" => false, "error" => %{"info" => reason}}),
    do: {:error, reason}
end
