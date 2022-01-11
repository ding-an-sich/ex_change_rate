defmodule ExChangeRateWeb.Params.CreateParams do
  @moduledoc """
  Schema for create input validation
  """

  use Ecto.Schema
  import Ecto.Changeset

  @fields ~w<user_id from to from_value>a
  @supported_currencies_list ExChangeRate.Utils.Currency.supported_currencies_list()

  embedded_schema do
    field(:user_id, Ecto.UUID)
    field(:from, :string)
    field(:to, :string)
    field(:from_value, :integer)
  end

  def changeset(changeset \\ %__MODULE__{}, params) do
    changeset
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_number(:from_value, greater_than: 0)
    |> validate_inclusion(:from, @supported_currencies_list)
    |> validate_inclusion(:to, @supported_currencies_list)
    |> validate_different_currencies
  end

  defp validate_different_currencies(%{valid?: false} = changeset), do: changeset

  defp validate_different_currencies(changeset) do
    from = get_change(changeset, :from)
    to = get_change(changeset, :to)

    if from == to do
      changeset
      |> add_error(:to, "target currency must be different than origin currency")
      |> add_error(:from, "origin currency must be different from target currency")
    else
      changeset
    end
  end
end
