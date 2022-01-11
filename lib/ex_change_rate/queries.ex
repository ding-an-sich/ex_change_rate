defmodule ExChangeRate.Queries do
  @moduledoc """
  Query functions
  """
  import Ecto.Query

  alias ExChangeRate.Models.ExchangeRateRequest
  alias ExChangeRate.Repo

  def list_by_user_id(user_id) do
    ExchangeRateRequest
    |> where(user_id: ^user_id)
    |> Repo.all()
  end
end
