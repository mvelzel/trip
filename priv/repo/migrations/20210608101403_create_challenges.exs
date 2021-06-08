defmodule Trip.Repo.Migrations.CreateChallenges do
  use Ecto.Migration

  def change do
    create table(:challenges) do
      add :name, :string
      add :description, :string
      add :max_score, :integer
      add :pass_or_fail, :boolean, default: false, null: false
      add :available, :boolean, default: false, null: false
      add :submission_type, :string

      timestamps()
    end

  end
end
