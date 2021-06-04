defmodule TripWeb.IndexLive do
  use TripWeb, :live_view

  alias Trip.{Locations, Posts, Accounts}

  @impl true
  def mount(_params, session, socket) do
    locations = Locations.list_locations()

    socket = assign_defaults(socket, session)

    location = Accounts.get_user_location(socket.assigns.current_user)
    post_locations = Posts.list_posts_locations(location.id)

    {:ok,
     socket
     |> assign(post_locations: post_locations)
     |> assign(locations: locations)
     |> assign(location: location)}
  end

  @impl true
  def handle_event("location-selected", %{"value" => id}, socket) do
    location = Locations.get_location!(id)
    post_locations = Posts.list_posts_locations(id)

    {:noreply,
     socket
     |> assign(post_locations: post_locations)
     |> assign(location: location)}
  end

  def handle_event("show-post", %{"post" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.posts_show_path(socket, :show, id))}
  end
end
