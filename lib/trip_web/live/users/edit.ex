defmodule TripWeb.UsersLive.Edit do
  use TripWeb, :live_view

  alias Trip.Accounts.User
  alias Trip.{Locations, Accounts, Groups}

  @impl true
  def mount(%{"user" => id}, session, socket) do
    locations = Locations.list_locations()
    user = Accounts.get_user!(id)
    groups = Groups.list_groups(user.group.location.id)

    changeset =
      user
      |> User.edit_changeset(%{})

    {:ok,
     socket
     |> assign_defaults(session)
     |> assign(locations: locations)
     |> assign(selected_location: user.group.location.id)
     |> assign(user: user)
     |> assign(groups: groups)
     |> assign(changeset: changeset)}
  end

  def mount(_params, session, socket) do
    locations = Locations.list_locations()

    changeset =
      %User{}
      |> User.registration_changeset(%{})

    {:ok,
     socket
     |> assign_defaults(session)
     |> assign(locations: locations)
     |> assign(selected_location: "")
     |> assign(changeset: changeset)}
  end

  def handle_event(
        "validate",
        %{"user" => user_params},
        %{assigns: %{live_action: :edit}} = socket
      ) do
    changeset =
      socket.assigns.user
      |> User.edit_changeset(user_params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %User{}
      |> User.registration_changeset(user_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "create",
        %{"user" => user_params},
        %{assigns: %{live_action: :edit}} = socket
      ) do
    {:ok, _} = Accounts.update_user(socket.assigns.user, user_params)

    {:noreply, push_redirect(socket, to: Routes.users_index_path(socket, :index))}
  end

  def handle_event("create", %{"user" => user_params}, socket) do
    {:ok, _} = Accounts.register_user(user_params)

    {:noreply, push_redirect(socket, to: Routes.users_index_path(socket, :index))}
  end

  def handle_event("location-selected", %{"value" => id}, socket) do
    groups = Groups.list_groups(id)

    {:noreply, 
      socket
      |> assign(selected_location: id)
      |> assign(groups: groups)}
  end

  def handle_event("group-selected", %{"value" => id}, socket) do
    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:group_id, id)
      |> Ecto.Changeset.put_assoc(:group, Groups.get_group!(id))
      |> User.validate_changeset()

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("role-selected", %{"value" => role}, socket) do
    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:role, role)
      |> User.validate_changeset()

    {:noreply, assign(socket, changeset: changeset)}
  end
end
