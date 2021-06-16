defmodule Trip.Repo.Migrations.DescToText do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      modify :description, :text
    end

    alter table(:challenges) do
      modify :description, :text
    end
  end
end
