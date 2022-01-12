defmodule ExChangeRateWeb.ApiSpec do
  @moduledoc """
  Application Open Api Spec
  """
  @behaviour OpenApi

  alias OpenApiSpex.{Info, OpenApi, Paths, Server}
  alias ExChangeRateWeb.{Endpoint, Router}

  @impl OpenApi
  def spec do
    OpenApiSpex.resolve_schema_modules(%OpenApi{
      servers: [
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: "ExChangeRate",
        version: "0.1.0"
      },
      paths: Paths.from_router(Router)
    })
  end
end
