defmodule TripWeb.PostsLive.Edit do
  use TripWeb, :live_view

  alias Trip.Posts.Post
  alias Trip.Locations

  @impl true
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

  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      %Post{}
      |> Post.changeset(post_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end
end
