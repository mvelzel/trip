defmodule Trip.Repo.Migrations.AlterUsersTable do
  use Ecto.Migration

  def change do
    rename table(:users), :email, to: :username
    alter table(:users) do
      add :role, :string
    end
  end
end
