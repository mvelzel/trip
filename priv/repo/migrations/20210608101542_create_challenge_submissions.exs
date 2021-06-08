defmodule Trip.Repo.Migrations.CreateChallengeSubmissions do
  use Ecto.Migration

  def change do
    create table(:challenge_submissions) do
      add :status, :string
      add :score, :integer
      add :text, :string
      add :image, :binary

      add :challenge_id, references(:challenges, on_delete: :nilify_all)
      add :group_id, references(:groups, on_delete: :delete_all)

      timestamps()
    end

  end
end
