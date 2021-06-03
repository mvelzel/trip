defmodule Trip.Repo.Migrations.GroupAddScore do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add :score, :integer
    end
  end
end
