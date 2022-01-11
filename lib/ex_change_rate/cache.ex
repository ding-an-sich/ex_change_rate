defmodule ExChangeRate.Cache do
  @moduledoc """
  Application cache
  """

  def get(key), do: Mentat.get(__MODULE__, key)

  def put(key, value), do: Mentat.put(__MODULE__, key, value)
end
