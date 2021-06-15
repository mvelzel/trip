defmodule Trip.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias Trip.Repo

  alias Trip.Notifications.Notification
  alias Trip.Accounts

  @doc """
  Returns the list of notifications.

  ## Examples

      iex> list_notifications()
      [%Notification{}, ...]

  """
  def list_notifications(user_id) do
    Notification
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def list_unread_notifications(user_id) do
    Notification
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
    |> where(read: false)
    |> Repo.all()
  end

  @doc """
  Gets a single notification.

  Raises `Ecto.NoResultsError` if the Notification does not exist.

  ## Examples

      iex> get_notification!(123)
      %Notification{}

      iex> get_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification!(id), do: Repo.get!(Notification, id)

  @doc """
  Creates a notification.

  ## Examples

      iex> create_notification(%{field: value})
      {:ok, %Notification{}}

      iex> create_notification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(attrs \\ %{}) do
    changeset =
      %Notification{}
      |> Notification.changeset(attrs)

    {:ok, notification} =
      changeset
      |> Repo.insert()

    Phoenix.PubSub.broadcast(Trip.PubSub, "notification:#{notification.user_id}", notification)
  end

  def notify_all_role(attrs, role) do
    for user <- Accounts.list_users_by_role(role) do
      create_notification(
        attrs
        |> Map.put("user_id", user.id)
      )
    end
  end

  def notify_all(attrs) do
    for user <- Accounts.list_users() do
      create_notification(
        attrs
        |> Map.put("user_id", user.id)
      )
    end
  end

  @doc """
  Updates a notification.

  ## Examples

      iex> update_notification(notification, %{field: new_value})
      {:ok, %Notification{}}

      iex> update_notification(notification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update()
  end

  def mark_all_read(user_id) do
    Notification
    |> where(user_id: ^user_id)
    |> Repo.update_all(set: [read: true])
  end

  def delete_all_read(user_id) do
    Notification
    |> where(user_id: ^user_id)
    |> where(read: true)
    |> Repo.delete_all()
  end

  def mark_as_read(not_id) do
    Notification
    |> where(id: ^not_id)
    |> Repo.update_all(set: [read: true])
  end

  @doc """
  Deletes a notification.

  ## Examples

      iex> delete_notification(notification)
      {:ok, %Notification{}}

      iex> delete_notification(notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification changes.

  ## Examples

      iex> change_notification(notification)
      %Ecto.Changeset{data: %Notification{}}

  """
  def change_notification(%Notification{} = notification, attrs \\ %{}) do
    Notification.changeset(notification, attrs)
  end
end
