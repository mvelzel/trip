defmodule Trip.Repo.Migrations.CreatePostLocations do
  use Ecto.Migration

  def change do
    create table(:post_locations) do
      add :latitude, :float
      add :longitude, :float
      add :post_id, references(:posts, on_delete: :delete_all)
      add :location_id, references(:locations, on_delete: :nilify_all)

      timestamps()
    end

    create unique_index(:post_locations,
      [:post_id, :location_id],
      name: :postlocuniq)
  end
end
