defmodule TripWeb.PostsLive.Show do
  use TripWeb, :live_view

  alias Trip.{Locations, Posts, Accounts}

  @impl true
  def mount(%{"post" => id}, session, socket) do
    locations = Locations.list_locations()
    post = Posts.get_post!(id)

    socket = assign_defaults(socket, session)

    location = Accounts.get_user_location(socket.assigns.current_user)

    post_locations =
      post.locations
      |> Enum.filter(&(&1.location.id == location.id))

    {:ok,
     socket
     |> assign(locations: locations)
     |> assign(location: location)
     |> assign(post_locations: post_locations)
     |> assign(post: post)}
  end

  @impl true
  def handle_event("location-selected", %{"value" => id}, socket) do
    location = Locations.get_location!(id)
    post_locations =
      socket.assigns.post.locations
      |> Enum.filter(&(&1.location.id == location.id))

    {:noreply,
     socket
     |> assign(post_locations: post_locations)
     |> assign(location: location)}
  end
end
