defmodule ExChangeRateWeb.ExchangeRatesControllerIntegrationTest do
  @moduledoc false

  use ExChangeRateWeb.IntegrationCase, async: false

  import ExChangeRate.Factory

  alias ExChangeRate.Models.ExchangeRateRequest
  alias ExChangeRate.Repo
  alias ExChangeRate.Utils.Currency
  alias ExChangeRate.Workers.ExchangeRateRequestsWorker

  @exchangerate_api_url "http://api.exchangeratesapi.io/v1/latest"

  describe "ex_change_rate" do
    test "should create an exchange rate request, process it and serve the correct result", %{
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
               } = pending_exchange_rate_request
             ] = Repo.all(ExchangeRateRequest)

      job_args = %{
        exchange_rate_request_id: pending_exchange_rate_request.id,
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
               } = completed_exchange_rate_request
             ] = Repo.all(ExchangeRateRequest)

      rates = response["rates"]
      rate = Currency.calculate_exchange_rate(rates[from], rates[to])

      assert to_value == Currency.convert(from_value, rate, to)

      get_endpoint_response =
        conn
        |> get("api/exchange_rates/#{user_id}")
        |> json_response(200)

      assert get_endpoint_response == [
               %{
                 "from" => completed_exchange_rate_request.from,
                 "from_value" =>
                   Currency.format_to_string(completed_exchange_rate_request.from_value),
                 "id" => completed_exchange_rate_request.id,
                 "rate" => Currency.format_to_string(completed_exchange_rate_request.rate),
                 "status" => "completed",
                 "timestamp" =>
                   NaiveDateTime.to_iso8601(completed_exchange_rate_request.inserted_at),
                 "to" => completed_exchange_rate_request.to,
                 "to_value" =>
                   Currency.format_to_string(completed_exchange_rate_request.to_value),
                 "user_id" => completed_exchange_rate_request.user_id
               }
             ]
    end

    test "should create an exchange rate request, fail it and show the failure reason", %{
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
               } = pending_exchange_rate_request
             ] = Repo.all(ExchangeRateRequest)

      job_args = %{
        exchange_rate_request_id: pending_exchange_rate_request.id,
        from: from,
        to: to,
        from_value: from_value
      }

      assert_enqueued(
        worker: ExchangeRateRequestsWorker,
        args: job_args
      )

      response = %{
        "success" => false,
        "error" => %{
          "code" => 123,
          "info" => "Something went very, very wrong"
        }
      }

      expect(TeslaMock, :call, fn %{
                                    method: :get,
                                    url: @exchangerate_api_url
                                  },
                                  _ ->
        {:ok, json(response, status: 200)}
      end)

      assert {:error, "Something went very, very wrong"} ==
               perform_job(ExchangeRateRequestsWorker, job_args, attempt: 3, max_attempts: 3)

      assert [
               %ExchangeRateRequest{
                 status: :failed,
                 user_id: ^user_id,
                 from: ^from,
                 to: ^to,
                 from_value: ^converted_from_value,
                 to_value: nil,
                 failure_reason: "\"Something went very, very wrong\"",
                 failed_at: %NaiveDateTime{}
               } = failed_exchange_rate_request
             ] = Repo.all(ExchangeRateRequest)

      get_endpoint_response =
        conn
        |> get("api/exchange_rates/#{user_id}")
        |> json_response(200)

      assert get_endpoint_response == [
               %{
                 "from" => failed_exchange_rate_request.from,
                 "from_value" =>
                   Currency.format_to_string(failed_exchange_rate_request.from_value),
                 "id" => failed_exchange_rate_request.id,
                 "status" => "failed",
                 "failure_reason" => failed_exchange_rate_request.failure_reason,
                 "timestamp" =>
                   NaiveDateTime.to_iso8601(failed_exchange_rate_request.inserted_at),
                 "to" => failed_exchange_rate_request.to,
                 "user_id" => failed_exchange_rate_request.user_id
               }
             ]
    end
  end
end
