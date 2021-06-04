defmodule TripWeb.GroupsLive.Edit do
  use TripWeb, :live_view

  alias Trip.Groups.Group
  alias Trip.{Locations, Groups}

  @impl true
  def mount(%{"group" => id}, session, socket) do
    locations = Locations.list_locations()
    group = Groups.get_group!(id)

    changeset =
      group
      |> Group.changeset(%{})

    {:ok,
     socket
     |> assign_defaults(session)
     |> assign(locations: locations)
     |> assign(group: group)
     |> assign(changeset: changeset)}
  end

  def mount(_params, session, socket) do
    locations = Locations.list_locations()

    changeset =
      %Group{}
      |> Group.changeset(%{})

    {:ok,
     socket
     |> assign_defaults(session)
     |> assign(locations: locations)
     |> assign(changeset: changeset)}
  end

  def handle_event(
        "validate",
        %{"group" => group_params},
        %{assigns: %{live_action: :edit}} = socket
      ) do
    changeset =
      socket.assigns.group
      |> Group.changeset(group_params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("validate", %{"group" => group_params}, socket) do
    changeset =
      %Group{}
      |> Group.changeset(group_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "create",
        %{"group" => group_params},
        %{assigns: %{live_action: :edit}} = socket
      ) do
    {:ok, _} = Groups.update_group(socket.assigns.group, group_params)

    {:noreply, push_redirect(socket, to: Routes.groups_index_path(socket, :index))}
  end

  def handle_event("create", %{"group" => group_params}, socket) do
    {:ok, _} = Groups.create_group(group_params)

    {:noreply, push_redirect(socket, to: Routes.groups_index_path(socket, :index))}
  end

  def handle_event("dropdown-selected", %{"value" => id}, socket) do
    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:location_id, id)
      |> Ecto.Changeset.put_assoc(:location, Locations.get_location!(id))
      |> Group.validate_changeset()

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove-group", _params, %{assigns: %{live_action: :edit}} = socket) do
    {:ok, _} = Groups.delete_group(socket.assigns.group)

    {:noreply, push_redirect(socket, to: Routes.groups_index_path(socket, :index))}
  end
end
