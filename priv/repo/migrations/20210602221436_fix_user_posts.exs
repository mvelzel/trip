defmodule Trip.Repo.Migrations.FixUserPosts do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE user_posts DROP CONSTRAINT user_posts_post_id_fkey"
    alter table(:user_posts) do
      modify :post_id, references(:posts, on_delete: :delete_all)
    end
  end
end
