defmodule Matching.Accounts.Trait do
  use Ecto.Schema
  import Ecto.Changeset

  schema "traits" do
    field(:name, :string)

    many_to_many(:users, Matching.Accounts.User, join_through: "user_traits")

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(trait, attrs) do
    trait
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
