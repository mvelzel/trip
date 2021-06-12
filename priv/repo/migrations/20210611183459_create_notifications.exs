defmodule Trip.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :read, :boolean, default: false, null: false
      add :text, :string
      add :priority, :string

      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

  end
end
