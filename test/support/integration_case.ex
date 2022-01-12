defmodule ExChangeRateWeb.IntegrationCase do
  @moduledoc """
  Module that imports and defines helpers for integration testing.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Mox
      import Tesla.Mock, only: [json: 2]

      use Oban.Testing, repo: ExChangeRate.Repo
      use ExChangeRateWeb.ConnCase

      setup do
        ExChangeRate.Cache.flush()

        :ok
      end

      setup :verify_on_exit!
      setup :set_mox_from_context
    end
  end
end
