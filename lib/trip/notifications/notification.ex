defmodule Trip.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  alias Trip.Accounts.User

  @priority_values [:normal, :urgent]

  @derive {Jason.Encoder, only: [:priority, :read, :text, :action, :id, :user_id]}
  schema "notifications" do
    field :priority, Ecto.Enum, values: @priority_values
    field :read, :boolean, default: false
    field :text, :string
    field :action, :string, default: nil

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:read, :text, :priority, :user_id, :action])
    |> validate_changeset()
  end

  def validate_changeset(changeset) do
    changeset
    |> Map.put(:errors, [])
    |> Map.put(:valid?, true)
    |> validate_required([:text, :priority, :user_id])
  end

  def priority_values, do: @priority_values
end
