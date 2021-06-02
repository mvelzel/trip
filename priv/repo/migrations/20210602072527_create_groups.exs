defmodule Trip.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string
      add :number, :integer
      add :girls_only, :boolean, default: false, null: false

      add :location_id, references(:locations, on_delete: :nilify_all)

      timestamps()
    end

  end
end
