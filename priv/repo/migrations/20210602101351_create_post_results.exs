defmodule Trip.Repo.Migrations.CreatePostResults do
  use Ecto.Migration

  def change do
    create table(:post_results) do
      add :score, :integer

      add :post_id, references(:posts, on_delete: :nilify_all)
      add :group_id, references(:groups, on_delete: :delete_all)

      timestamps()
    end

  end
end
