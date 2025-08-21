defmodule Matching.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "users" do
    field :name, :string
    field :email, :string
    field :abo, :string
    field :rh, :string
    field :canton, :string
    field :role, Ecto.Enum, values: [:donor, :recipient, :both], default: :recipient

    field :trait_ids, {:array, :integer}, virtual: true

    many_to_many :traits, Matching.Accounts.Trait,
      join_through: "user_traits",
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :abo, :rh, :canton, :role, :trait_ids])
    |> validate_required([:name, :email, :abo, :rh, :canton, :role])
    |> validate_inclusion(:role, [:donor, :recipient, :both])
    |> put_assoc_from_ids(:traits, :trait_ids)
  end

  defp put_assoc_from_ids(changeset, assoc_field, id_field) do
    ids = get_change(changeset, id_field, []) || []
    query = from t in Matching.Accounts.Trait, where: t.id in ^ids
    assoc_structs = Matching.Repo.all(query)
    put_assoc(changeset, assoc_field, assoc_structs)
  end
end
