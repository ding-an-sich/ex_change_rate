defmodule ExChangeRate.FactoryHelpers do
  @moduledoc """
  Helper functions for inserting and building factories
  """

  import ExChangeRate.Factory

  def build_with_status(factory_name, status, params \\ %{}) do
    factory_name
    |> build(params)
    |> with_status(status)
    |> ExMachina.merge_attributes(params)
  end

  def insert_with_status(factory_name, status, params \\ %{}) do
    factory_name
    |> build_with_status(status, params)
    |> ExChangeRate.Factory.insert()
  end
end
