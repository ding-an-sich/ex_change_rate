defmodule ExChangeRateWeb.ExchangeRatesControllerTest do
  use ExChangeRateWeb.ConnCase, async: true

  import ExChangeRate.Factory
  import ExChangeRate.FactoryHelpers

  alias ExChangeRate.Utils.Currency

  describe "index/2" do
    setup do
      user_id = Ecto.UUID.generate()
      pending_exrr = insert(:exchange_rate_request, user_id: user_id)

      completed_exrr =
        insert_with_status(
          :exchange_rate_request,
          :completed,
          user_id: user_id
        )

      failed_exrr =
        insert_with_status(
          :exchange_rate_request,
          :failed,
          user_id: user_id
        )

      %{
        pending_exrr: pending_exrr,
        completed_exrr: completed_exrr,
        failed_exrr: failed_exrr,
        user_id: user_id
      }
    end

    test "should list entries for a given user_id", ctx do
      conn = ctx.conn
      user_id = ctx.user_id

      response =
        conn
        |> get("api/exchange_rates/#{user_id}")
        |> json_response(200)

      pending_exrr = ctx.pending_exrr
      completed_exrr = ctx.completed_exrr
      failed_exrr = ctx.failed_exrr

      assert [
               %{
                 "from" => pending_exrr.from,
                 "to" => pending_exrr.to,
                 "from_value" => Currency.format_to_string(pending_exrr.from_value),
                 "status" => "pending",
                 "timestamp" => NaiveDateTime.to_iso8601(pending_exrr.inserted_at),
                 "user_id" => user_id,
                 "id" => pending_exrr.id
               },
               %{
                 "from" => completed_exrr.from,
                 "to" => completed_exrr.to,
                 "from_value" => Currency.format_to_string(completed_exrr.from_value),
                 "status" => "completed",
                 "timestamp" => NaiveDateTime.to_iso8601(completed_exrr.inserted_at),
                 "user_id" => user_id,
                 "to_value" => Currency.format_to_string(completed_exrr.to_value),
                 "rate" => Currency.format_to_string(completed_exrr.rate),
                 "id" => completed_exrr.id
               },
               %{
                 "from" => failed_exrr.from,
                 "to" => failed_exrr.to,
                 "from_value" => Currency.format_to_string(failed_exrr.from_value),
                 "status" => "failed",
                 "timestamp" => NaiveDateTime.to_iso8601(failed_exrr.inserted_at),
                 "user_id" => user_id,
                 "failure_reason" => failed_exrr.failure_reason,
                 "id" => failed_exrr.id
               }
             ] == response
    end

    test "should show an empty list when a user_id has no associated records", ctx do
      conn = ctx.conn
      user_id = Ecto.UUID.generate()

      assert [] ==
               conn
               |> get("api/exchange_rates/#{user_id}")
               |> json_response(200)
    end

    test "should flag a validation error when receiving an invalid user_id", ctx do
      conn = ctx.conn
      user_id = "my_id"

      assert %{"errors" => %{"reason" => "user_id must be an UUID"}} =
               conn
               |> get("api/exchange_rates/#{user_id}")
               |> json_response(400)
    end
  end

  describe "create/2" do
  end
end
