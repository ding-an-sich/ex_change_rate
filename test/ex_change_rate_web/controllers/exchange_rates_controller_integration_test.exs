defmodule ExChangeRateWeb.ExchangeRatesControllerIntegrationTest do
  @moduledoc false

  use ExChangeRateWeb.IntegrationCase, async: false

  import ExChangeRate.Factory

  alias ExChangeRate.Models.ExchangeRateRequest
  alias ExChangeRate.Repo
  alias ExChangeRate.Utils.Currency
  alias ExChangeRate.Workers.ExchangeRateRequestsWorker

  @exchangerate_api_url "http://api.exchangeratesapi.io/v1/latest"

  describe "create/2" do
    test "should create an exchange rate request, proccess it and serve the correct result", %{
      conn: conn
    } do
      params = string_params_for(:create_params)

      assert conn
             |> post("api/exchange_rates", params)
             |> response(202)

      user_id = params["user_id"]
      from = params["from"]
      to = params["to"]
      from_value = params["from_value"]
      converted_from_value = Currency.new(from_value, from)

      assert [
               %ExchangeRateRequest{
                 status: :pending,
                 user_id: ^user_id,
                 from: ^from,
                 to: ^to,
                 from_value: ^converted_from_value
               } = exchange_rate_request
             ] = Repo.all(ExchangeRateRequest)

      exchange_rate_request_id = exchange_rate_request.id

      job_args = %{
        exchange_rate_request_id: exchange_rate_request_id,
        from: from,
        to: to,
        from_value: from_value
      }

      assert_enqueued(
        worker: ExchangeRateRequestsWorker,
        args: job_args
      )

      response = %{
        "success" => true,
        "rates" => %{
          from => 2.350000,
          to => 1
        }
      }

      expect(TeslaMock, :call, fn %{
                                    method: :get,
                                    url: @exchangerate_api_url
                                  },
                                  _ ->
        {:ok, json(response, status: 200)}
      end)

      assert :ok == perform_job(ExchangeRateRequestsWorker, job_args)

      assert [
               %ExchangeRateRequest{
                 status: :completed,
                 user_id: ^user_id,
                 from: ^from,
                 to: ^to,
                 from_value: ^converted_from_value,
                 to_value: to_value
               }
             ] = Repo.all(ExchangeRateRequest)

      rates = response["rates"]
      rate = Currency.calculate_exchange_rate(rates[from], rates[to])

      assert to_value == Currency.convert(from_value, rate, to)
    end
  end
end
