defmodule Trip.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :started, :boolean, default: false, null: false
      add :current_round, :integer
      add :time_started, :naive_datetime

      timestamps()
    end

  end
end
