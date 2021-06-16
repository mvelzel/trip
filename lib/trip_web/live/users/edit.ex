defmodule TripWeb.UsersLive.Edit do
  use TripWeb, :live_view
  import Trip.ChangesetHelpers

  alias Trip.Accounts.{User, UserPost}
  alias Trip.{Locations, Accounts, Groups, Posts}

  @impl true
  def mount(%{"user" => id}, session, socket) do
    locations = Locations.list_locations()
    posts = Posts.list_posts()
    user = Accounts.get_user!(id)
    {selected_location, groups} = if user.group && user.group.location do
      {user.group.location.id, Groups.list_groups(user.group.location.id)}
    else
      {"", []}
    end

    changeset =
      user
      |> User.edit_changeset(%{})

    {:ok,
     socket
     |> assign_defaults(session)
     |> assign(locations: locations)
     |> assign(selected_location: selected_location)
     |> assign(user: user)
     |> assign(groups: groups)
     |> assign(posts: posts)
     |> assign(changeset: changeset)}
  end

  def mount(_params, session, socket) do
    locations = Locations.list_locations()
    posts = Posts.list_posts()

    changeset =
      %User{}
      |> User.registration_changeset(%{})

    {:ok,
     socket
     |> assign_defaults(session)
     |> assign(locations: locations)
     |> assign(posts: posts)
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

    {changeset, socket} =
      case to_string(role) do
        "player" ->
          {changeset
           |> Ecto.Changeset.put_assoc(:posts, [])
           |> User.validate_changeset(), socket}

        "postleader" ->
          {changeset
           |> Ecto.Changeset.put_change(:group_id, nil)
           |> User.validate_changeset(), assign(socket, selected_location: "")}

        _ ->
          {changeset
           |> Ecto.Changeset.put_change(:group_id, nil)
           |> Ecto.Changeset.put_assoc(:posts, [])
           |> User.validate_changeset(), assign(socket, selected_location: "")}
      end

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("post-selected", %{"value" => id}, socket) do
    changeset =
      socket.assigns.changeset
      |> put_nested([:posts], fn chs ->
        chs
        |> Enum.concat([
          UserPost.changeset(
            %UserPost{post_id: id}
            |> Trip.Repo.preload(:post),
            %{}
          )
        ])
      end)
      |> User.validate_changeset()
    
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove-user", _params, %{assigns: %{live_action: :edit}} = socket) do
    {:ok, _} = Accounts.delete_user(socket.assigns.user)

    {:noreply, push_redirect(socket, to: Routes.users_index_path(socket, :index))}
  end
end
