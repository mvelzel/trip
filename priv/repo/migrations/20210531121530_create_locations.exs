defmodule Trip.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :longitude_bottomleft, :float
      add :latitude_bottomleft, :float
      add :longitude_topright, :float
      add :latitude_topright, :float

      timestamps()
    end

  end
end
