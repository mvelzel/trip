defmodule Trip.Repo.Migrations.ChangeLocPrimary do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      remove :id
      add :id, :serial, primary_key: true
    end
  end
end
