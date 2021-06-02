defmodule Trip.Repo.Migrations.UsersAddGroup do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :group_id, references(:groups, on_delete: :nilify_all)
    end
  end
end
