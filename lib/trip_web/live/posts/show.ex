defmodule TripWeb.PostsLive.Show do
  use TripWeb, :live_view

  alias Trip.{Locations, Posts, Accounts, Groups}

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

  def handle_event("show-post", %{"post" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.posts_show_path(socket, :show, id))}
  end

  def handle_event("claim-post", _params, socket) do
    current_user = socket.assigns.current_user

    group =
      case current_user.role do
        :player -> current_user.group
        _ -> Enum.at(Groups.list_groups(), 0)
      end

    post_location =
      socket.assigns.post_locations
      |> Enum.find(&(&1.location_id == group.location_id))

    round = 0

    Posts.create_post_claim(%{
      "post_location_id" => post_location.id,
      "group_id" => group.id,
      "round" => to_string(round)
    })

    {:noreply,
     push_redirect(socket, to: Routes.posts_show_path(socket, :show, socket.assigns.post.id))}
  end
end
