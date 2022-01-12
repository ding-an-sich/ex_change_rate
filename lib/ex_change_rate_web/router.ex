defmodule ExChangeRateWeb.Router do
  use ExChangeRateWeb, :router

  alias OpenApiSpex.Plug.{PutApiSpec, RenderSpec, SwaggerUI}

  @swagger_ui_config [
    path: "/api/openapi"
  ]

  pipeline :api do
    plug :accepts, ["json"]
    plug PutApiSpec, module: ExChangeRateWeb.ApiSpec
  end

  pipeline :browser do
    plug :accepts, ["html"]
  end

  scope "/api" do
    pipe_through :api

    get "/openapi", RenderSpec, []

    scope "/exchange_rates", ExChangeRateWeb do
      get "/:user_id", ExchangeRatesController, :index
      post "/", ExchangeRatesController, :create
    end
  end

  scope "/" do
    pipe_through :browser

    get "/swaggerui", SwaggerUI, @swagger_ui_config
  end
end
