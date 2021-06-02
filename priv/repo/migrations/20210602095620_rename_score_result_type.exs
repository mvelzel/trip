defmodule Trip.Repo.Migrations.RenameScoreResultType do
  use Ecto.Migration

  def change do
    rename table(:posts), :score_type, to: :result_type
  end
end
