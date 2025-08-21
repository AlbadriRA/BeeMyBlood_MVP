defmodule Matching.Repo.Migrations.AddCantonToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :canton, :string
    end
  end
end
