defmodule Trip.Repo.Migrations.AddVideoThumbnailChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :thumbnail, :binary
    end

    alter table(:challenge_submissions) do
      add :video, :binary
    end
  end
end
