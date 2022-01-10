defmodule ExChangeRateWeb.Router do
  use ExChangeRateWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ExChangeRateWeb do
    pipe_through :api

    resources "/exchange_rates",
              ExchangeRatesController,
              only: [:index, :create]
  end
end
