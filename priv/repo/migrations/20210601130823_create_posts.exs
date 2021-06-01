defmodule Trip.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :name, :string
      add :number, :integer
      add :description, :string

      timestamps()
    end

  end
end
