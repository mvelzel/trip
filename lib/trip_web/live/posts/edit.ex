defmodule TripWeb.PostsLive.Edit do
  use TripWeb, :live_view
  import Trip.ChangesetHelpers
  import TripWeb.NestedFormHelpers

  alias Trip.Posts.{Post, PostLocation}
  alias Trip.{Locations, Posts}

  @impl true
  def mount(%{"post" => id}, session, socket) do
    locations = Locations.list_locations()
    post = Posts.get_post!(id)

    changeset =
      post
      |> Post.changeset(%{})

    {:ok,
     socket
     |> assign_defaults(session)
     |> assign(locations: locations)
     |> assign(post: post)
     |> assign(changeset: changeset)}
  end

  def mount(_params, session, socket) do
    locations = Locations.list_locations()

    changeset =
      %Post{}
      |> Post.changeset(%{})

    {:ok,
     socket
     |> assign_defaults(session)
     |> assign(locations: locations)
     |> assign(changeset: changeset)}
  end

  def handle_event(
        "validate",
        %{"post" => post_params},
        %{assigns: %{live_action: :edit}} = socket
      ) do
    changeset =
      socket.assigns.post
      |> Post.changeset(post_params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      %Post{}
      |> Post.changeset(post_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "create",
        %{"post" => post_params},
        %{assigns: %{live_action: :edit}} = socket
      ) do
    {:ok, _} = Posts.update_post(socket.assigns.post, post_params)

    {:noreply, push_redirect(socket, to: Routes.posts_index_path(socket, :index))}
  end

  def handle_event("create", %{"post" => post_params}, socket) do
    {:ok, _} = Posts.create_post(post_params)

    {:noreply, push_redirect(socket, to: Routes.posts_index_path(socket, :index))}
  end

  def handle_event("dropdown-selected", %{"value" => id}, socket) do
    changeset =
      socket.assigns.changeset
      |> put_nested([:locations], fn chs ->
        chs
        |> Enum.concat([
          PostLocation.changeset(
            %PostLocation{
              location_id: id
            }
            |> Trip.Repo.preload(:location),
            %{}
          )
        ])
      end)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("set-location", %{"location" => [lat, lon], "cursor" => cursor}, socket) do
    changeset =
      socket.assigns.changeset
      |> change_nested(cursor, :latitude, lat)
      |> change_nested(cursor, :longitude, lon)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("set-location", _params, socket) do
    {:noreply, socket}
  end
end
