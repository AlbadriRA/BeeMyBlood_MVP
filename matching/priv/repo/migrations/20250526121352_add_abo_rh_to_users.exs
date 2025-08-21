defmodule Matching.Repo.Migrations.AddAboRhToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :abo, :string
      add :rh, :string
    end
  end
end
