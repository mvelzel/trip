defmodule Trip.Repo.Migrations.RenameLocations do
  use Ecto.Migration

  def change do
    rename table(:locations), :latitude_bottomleft, to: :lat0
    rename table(:locations), :longitude_bottomleft, to: :lon0
    rename table(:locations), :latitude_topright, to: :lat1
    rename table(:locations), :longitude_topright, to: :lon1
  end
end
