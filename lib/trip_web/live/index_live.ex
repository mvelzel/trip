defmodule TripWeb.IndexLive do
  use TripWeb, :live_view

  alias Trip.{Locations, Posts, Accounts}
  alias TripWeb.PostsLive.Show

  @impl true
  def mount(_params, session, socket) do
    locations = Locations.list_locations()

    socket = assign_defaults(socket, session)

    location = Accounts.get_user_location(socket.assigns.current_user)
    post_locations = if location do 
      Posts.list_posts_locations(location.id)
    else
      []
    end

    post_states =
      Show.generate_post_states(
        socket.assigns.current_user,
        post_locations,
        socket.assigns.game
      )

    Phoenix.PubSub.subscribe(Trip.PubSub, "post_claims")

    {:ok,
     socket
     |> assign(post_locations: post_locations)
     |> assign(post_states: post_states)
     |> assign(locations: locations)
     |> assign(location: location)}
  end

  @impl true
  def handle_event("location-selected", %{"value" => id}, socket) do
    location = Locations.get_location!(id)
    post_locations = Posts.list_posts_locations(id)

    post_states =
      Show.generate_post_states(
        socket.assigns.current_user,
        post_locations,
        socket.assigns.game
      )

    {:noreply,
     socket
     |> assign(post_locations: post_locations)
     |> assign(post_states: post_states)
     |> assign(location: location)}
  end

  def handle_event("show-post", %{"post" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.posts_show_path(socket, :show, id))}
  end

  @impl true
  def handle_info(:post_claims, socket) do
    post_states =
      Show.generate_post_states(
        socket.assigns.current_user,
        socket.assigns.post_locations,
        socket.assigns.game
      )

    {:noreply,
     socket
     |> assign(post_states: post_states)}
  end
end
