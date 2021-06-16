defmodule Trip.Repo.Migrations.ChangeVideoPath do
  use Ecto.Migration

  def change do
    alter table(:challenge_submissions) do
      modify :video, :string
    end
  end
end
