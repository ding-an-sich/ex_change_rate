defmodule ExChangeRate.ExchangeratesAPITest do
  use ExChangeRate.DataCase, async: true

  import ExUnit.CaptureLog
  import Mox
  import Tesla.Mock, only: [json: 2]

  alias ExChangeRate.Clients.ExchangeratesAPI

  @exchangerate_api_url "http://api.exchangeratesapi.io/v1/latest"

  setup :verify_on_exit!
  setup :set_mox_from_context

  describe "call/1" do
    test "should call the api and parse the success response body" do
      from = "USD"
      to = "EUR"

      response = %{
        "success" => true,
        "rates" => %{
          from => 2.350000,
          to => 1
        }
      }

      expect(TeslaMock, :call, fn %{method: :get, url: @exchangerate_api_url}, _ ->
        {:ok, json(response, status: 200)}
      end)

      assert {:ok, %{"USD" => 2.35000, "EUR" => 1}} ==
               ExchangeratesAPI.call(%{from: from, to: to})
    end

    test "should call the api and parse the failure response body" do
      from = "USD"
      to = "EUR"

      response = %{
        "success" => false,
        "error" => %{
          "info" => "World has ended in a nuclear war"
        }
      }

      expect(TeslaMock, :call, fn %{method: :get, url: @exchangerate_api_url}, _ ->
        {:ok, json(response, status: 200)}
      end)

      assert {:error, "World has ended in a nuclear war"} ==
               ExchangeratesAPI.call(%{from: from, to: to})
    end

    test "should fetch from cache from two subsequent calls" do
      from = "USD"
      to = "EUR"

      response = %{
        "success" => true,
        "rates" => %{
          from => 2.350000,
          to => 1
        }
      }

      expect(TeslaMock, :call, 1, fn %{method: :get, url: @exchangerate_api_url}, _ ->
        {:ok, json(response, status: 200)}
      end)

      Logger.configure(level: :debug)

      assert capture_log(fn ->
               assert {:ok, %{"USD" => 2.35000, "EUR" => 1}} ==
                        ExchangeratesAPI.call(%{from: from, to: to})
             end) =~ "Cache miss!"

      assert capture_log(fn ->
               assert {:ok, %{"USD" => 2.35000, "EUR" => 1}} ==
                        ExchangeratesAPI.call(%{from: from, to: to})
             end) =~ "Cache hit!"

      Logger.configure(level: :warn)
    end

    test "should fetch from cache when a subsequent call has `from` and `to` swapped" do
      from = "USD"
      to = "EUR"

      response = %{
        "success" => true,
        "rates" => %{
          from => 2.350000,
          to => 1
        }
      }

      expect(TeslaMock, :call, 1, fn %{method: :get, url: @exchangerate_api_url}, _ ->
        {:ok, json(response, status: 200)}
      end)

      Logger.configure(level: :debug)

      assert capture_log(fn ->
               assert {:ok, %{"USD" => 2.35000, "EUR" => 1}} ==
                        ExchangeratesAPI.call(%{from: from, to: to})
             end) =~ "Cache miss!"

      assert capture_log(fn ->
               assert {:ok, %{"USD" => 2.35000, "EUR" => 1}} ==
                        ExchangeratesAPI.call(%{from: to, to: from})
             end) =~ "Cache hit!"

      Logger.configure(level: :warn)
    end
  end
end
