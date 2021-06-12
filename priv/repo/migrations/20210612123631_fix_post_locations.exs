defmodule Trip.Repo.Migrations.FixPostLocations do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE post_locations DROP CONSTRAINT post_locations_location_id_fkey;"
    alter table(:post_locations) do
      modify :location_id, references(:locations, on_delete: :delete_all)
    end
  end
end
