defmodule Trip.Repo.Migrations.CreatePostClaims do
  use Ecto.Migration

  def change do
    create table(:post_claims) do
      add :round, :integer
      add :group_id, references(:groups, on_delete: :delete_all)
      add :post_location_id, references(:post_locations, on_delete: :delete_all)

      timestamps()
    end

  end
end
