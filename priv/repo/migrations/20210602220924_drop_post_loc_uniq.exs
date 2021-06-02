defmodule Trip.Repo.Migrations.DropPostLocUniq do
  use Ecto.Migration

  def change do
    drop unique_index(:post_locations, [:post_id, :location_id], name: :postlocuniq)
  end
end
