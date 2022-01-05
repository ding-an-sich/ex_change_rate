defmodule ExChangeRateWeb.Router do
  use ExChangeRateWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ExChangeRateWeb do
    pipe_through :api
  end
end
