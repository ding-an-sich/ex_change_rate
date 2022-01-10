defmodule ExChangeRate.Models.ExchangeRateRequest do
  use Ecto.Schema

  import Ecto.Changeset

  @fields ~w<user_id from to from_value to_value rate>a
  @required_create_fields ~w<user_id from to from_value>a

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "exchange_rate_requests" do
    field(:user_id, Ecto.UUID)
    field(:from, :string)
    field(:to, :string)
    field(:from_value, :integer)
    field(:to_value, :integer)
    field(:rate, :decimal)

    field(:status, Ecto.Enum,
      values: [
        :pending,
        :failed,
        :completed
      ],
      default: :pending
    )

    timestamps()
  end

  def changeset(changeset \\ %__MODULE__{}, params) do
    changeset
    |> cast(params, @fields)
    |> validate_required(@required_create_fields)
  end
end
