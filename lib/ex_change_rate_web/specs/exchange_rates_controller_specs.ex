defmodule ExChangeRateWeb.Specs.ExchangeRateControllerSpecs do
  defmacro __using__(_opts \\ []) do
    quote location: :keep do
      use OpenApiSpex.ControllerSpecs

      alias ExChangeRateWeb.Schemas

      tags [:exchange_rates]

      operation :index,
        summary: "Lists all exchange rate requests of an user",
        parameters: [
          user_id: [
            in: :path,
            description: "User ID",
            type: :string,
            example: "a5965bb5-5228-4d6b-9a1e-07c10b09cd74"
          ]
        ],
        responses: [
          ok: {"Exchange rates response", "application/json", Schemas.ExchangeRatesResponse}
        ]

      operation :create,
        summary: "Creates a new exchange rate request",
        request_body: {
          "Exchange rate request create params",
          "application/json",
          Schemas.ExchangeRateCreateParams,
          required: true
        },
        responses: [
          {:accepted, "Exchange rate request was accepted"}
        ]
    end
  end
end
