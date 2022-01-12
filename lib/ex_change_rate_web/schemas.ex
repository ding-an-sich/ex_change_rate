defmodule ExChangeRateWeb.Schemas do
  @moduledoc """
  Open Api schema
  """
  alias OpenApiSpex.Schema
  require OpenApiSpex

  defmodule ExchangeRateCreateParams do
    @moduledoc """
    ExchangeRateCreateParams schema
    """
    OpenApiSpex.schema(%{
      title: "Exchange rate operation create params",
      description: "Creates a new exchange rate request to be processed by the application",
      type: :object,
      properties: %{
        user_id: %Schema{
          type: :string,
          description: "User UUID"
        },
        from: %Schema{
          type: :string,
          description: "Three letter origin currency code"
        },
        to: %Schema{
          type: :string,
          description: "Three letter target currency code"
        },
        from_value: %Schema{
          type: :integer,
          description: "Value in cents in origin currency"
        }
      },
      required: [:user_id, :from, :to, :from_value],
      example: %{
        "user_id" => "a5965bb5-5228-4d6b-9a1e-07c10b09cd74",
        "from" => "USD",
        "to" => "BRL",
        "from_value" => 250_000
      }
    })
  end

  defmodule ExchangeRate do
    @moduledoc """
    ExchangeRate schema
    """
    OpenApiSpex.schema(%{
      title: "Exchange rate operation",
      description: "Holds exchange rate information for a pair of currencies",
      type: :object,
      properties: %{
        id: %Schema{
          type: :string,
          description: "Exchange rate request UUID"
        },
        user_id: %Schema{
          type: :string,
          description: "User UUID"
        },
        from: %Schema{
          type: :string,
          description: "Three letter origin currency code"
        },
        to: %Schema{
          type: :string,
          description: "Three letter target currency code"
        },
        from_value: %Schema{
          type: :string,
          description: "Value in origin currency"
        },
        to_value: %Schema{
          type: :string,
          description: "Value in target currency"
        },
        rate: %Schema{
          type: :string,
          description: "Rate used for conversion of origin currency to target currency"
        },
        status: %Schema{
          type: :string,
          description: "Current status of operation",
          enum: ["pending", "completed", "failed"]
        },
        failure_reason: %Schema{
          type: :string,
          description: "Failure reason of the operation, if any"
        },
        timestamp: %Schema{
          type: :string,
          description: "Request creation datetime in UTC",
          format: :"date-time"
        }
      },
      required: [:user_id, :from, :to, :from_value]
    })
  end

  defmodule ExchangeRatesResponse do
    @moduledoc """
    ExchangeRatesResponse schema
    """
    OpenApiSpex.schema(%{
      title: "Exchange rates response",
      description: "Response schema for a list of exchange rates",
      type: :array,
      items: ExchangeRate
    })
  end
end
