defmodule Matching.Repo.Migrations.CreateTraits do
  use Ecto.Migration

  def change do
    create table(:traits) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
