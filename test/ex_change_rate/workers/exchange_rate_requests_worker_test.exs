defmodule ExChangeRate.Workers.ExchangeRateRequestsWorkerTest do
  @moduledoc false

  use ExChangeRate.DataCase
  use Oban.Testing, repo: Repo

  import ExChangeRate.Factory
  import Mock

  alias ExChangeRate.Clients.ExchangeratesAPI
  alias ExChangeRate.Models.ExchangeRateRequest
  alias ExChangeRate.Utils.Currency
  alias ExChangeRate.Workers.ExchangeRateRequestsWorker, as: Worker

  describe "perform/1" do
    setup do
      %{
        exchange_rate_request: insert(:exchange_rate_request, from: "USD", to: "BRL")
      }
    end

    setup_with_mocks([
      {ExchangeratesAPI, [],
       [
         call: fn _ -> {:ok, %{"USD" => 1.2342, "BRL" => 7.2312}} end
       ]}
    ]) do
      :ok
    end

    test "should fetch exchange rate information and complete a request",
         %{
           exchange_rate_request: exchange_rate_request
         } do
      assert :ok ==
               perform_job(Worker, %{
                 "from" => exchange_rate_request.from,
                 "to" => exchange_rate_request.to,
                 "from_value" => Currency.get_value(exchange_rate_request.from_value),
                 "exchange_rate_request_id" => exchange_rate_request.id
               })

      assert [
               %ExchangeRateRequest{
                 status: :completed,
                 from_value: from_value,
                 to_value: to_value,
                 rate: rate,
                 to: to
               }
             ] = Repo.all(ExchangeRateRequest)

      from_rate = 1.2342
      to_rate = 7.2312
      assert rate == Currency.calculate_exchange_rate(from_rate, to_rate)
      assert to_value == Currency.convert(Currency.get_value(from_value), rate, to)
    end

    test "should be discarded when failing because of a record not found", %{
      exchange_rate_request: exchange_rate_request
    } do
      assert {:discard, "record not found"} ==
               perform_job(Worker, %{
                 "from" => exchange_rate_request.from,
                 "to" => exchange_rate_request.to,
                 "from_value" => Currency.get_value(exchange_rate_request.from_value),
                 "exchange_rate_request_id" => Ecto.UUID.generate()
               })
    end

    test "should error out when the api call fails", %{
      exchange_rate_request: exchange_rate_request
    } do
      with_mock ExchangeratesAPI, call: fn _ -> {:error, "some error"} end do
        assert {:error, "some error"} ==
                 perform_job(Worker, %{
                   "from" => exchange_rate_request.from,
                   "to" => exchange_rate_request.to,
                   "from_value" => Currency.get_value(exchange_rate_request.from_value),
                   "exchange_rate_request_id" => exchange_rate_request.id
                 })
      end
    end

    test "in the last attempt, should mark the request as failed before erroring out", %{
      exchange_rate_request: exchange_rate_request
    } do
      with_mock ExchangeratesAPI, call: fn _ -> {:error, "some error"} end do
        assert {:error, "some error"} ==
                 Worker.perform(%{
                   attempt: 3,
                   max_attempts: 3,
                   args: %{
                     "from" => exchange_rate_request.from,
                     "to" => exchange_rate_request.to,
                     "from_value" => Currency.get_value(exchange_rate_request.from_value),
                     "exchange_rate_request_id" => exchange_rate_request.id
                   }
                 })

        assert [%ExchangeRateRequest{status: :failed, failure_reason: "\"some error\""}] =
                 Repo.all(ExchangeRateRequest)
      end
    end
  end
end
