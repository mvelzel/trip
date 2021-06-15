defmodule Trip.Repo.Migrations.NotificationAddAction do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      add :action, :string
    end
  end
end
