defmodule Trip.Repo.Migrations.AddScoreType do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :score_type, :string
    end
  end
end
