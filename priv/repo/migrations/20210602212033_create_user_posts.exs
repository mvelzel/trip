defmodule Trip.Repo.Migrations.CreateUserPosts do
  use Ecto.Migration

  def change do
    create table(:user_posts) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :post_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:user_posts,
      [:post_id, :user_id],
      name: :userpostuniq)
  end
end
