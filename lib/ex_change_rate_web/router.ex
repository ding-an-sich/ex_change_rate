defmodule ExChangeRateWeb.Router do
  use ExChangeRateWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ExChangeRateWeb do
    pipe_through :api

    scope "/exchange_rates" do
      get "/:user_id", ExchangeRatesController, :index
      post "/", ExchangeRatesController, :create
    end
  end
end
