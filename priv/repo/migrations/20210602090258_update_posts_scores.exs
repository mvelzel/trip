defmodule Trip.Repo.Migrations.UpdatePostsScores do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :score_type, :string
      add :score_divisions, {:array, :map}, default: []
    end
  end
end
