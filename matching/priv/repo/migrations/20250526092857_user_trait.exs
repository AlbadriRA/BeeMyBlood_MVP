defmodule Matching.Repo.Migrations.UserTrait do
  use Ecto.Migration

  def change do
    create table(:user_traits, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :trait_id, references(:traits, on_delete: :delete_all), null: false
    end

    create unique_index(:user_traits, [:user_id, :trait_id])
  end
end
