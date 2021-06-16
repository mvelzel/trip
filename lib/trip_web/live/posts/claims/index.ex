defmodule TripWeb.PostsLive.Claims.Index do
  use TripWeb, :live_view

  alias Trip.{Posts, Locations}

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    locations = Locations.list_locations()
    location = Enum.at(locations, 0)
    posts = Posts.list_posts()
    post = Enum.at(posts, 0)

    {post_location, post_claims} =
      if post do
        loc =
          post.locations
          |> Enum.find(&(&1.location_id == location.id))
        {
          loc,
          Posts.list_all_post_claims(loc.id)
          |> Enum.sort_by(& &1.round, :desc)
        }
      else
        {nil, []}
      end

    {:ok,
     socket
     |> assign(locations: locations)
     |> assign(location: location)
     |> assign(post_claims: post_claims)
     |> assign(post_location: post_location)
     |> assign(post: post)
     |> assign(posts: posts)}
  end

  @impl true
  def handle_event("delete-claim", %{"index" => index}, socket) do
    post_claim =
      socket.assigns.post_claims
      |> Enum.at(String.to_integer(index))

    Posts.delete_post_claim(post_claim)

    post_claims =
      Posts.list_all_post_claims(socket.assigns.post_location.id)
      |> Enum.sort_by(& &1.round, :desc)

    {:noreply,
     socket
     |> assign(post_claims: post_claims)}
  end

  def handle_event("post-selected", %{"value" => id}, socket) do
    post = Posts.get_post!(id)

    post_location =
      post.locations
      |> Enum.find(&(&1.location_id == socket.assigns.location.id))

    post_claims =
      Posts.list_all_post_claims(post_location.id)
      |> Enum.sort_by(& &1.round, :desc)

    {:noreply,
     socket
     |> assign(post: post)
     |> assign(post_claims: post_claims)
     |> assign(post_location: post_location)}
  end

  def handle_event("location-selected", %{"value" => id}, socket) do
    location = Locations.get_location!(id)

    post_location =
      socket.assigns.post.locations
      |> Enum.find(&(&1.location_id == location.id))

    post_claims =
      Posts.list_all_post_claims(post_location.id)
      |> Enum.sort_by(& &1.round, :desc)

    {:noreply,
     socket
     |> assign(location: location)
     |> assign(post_claims: post_claims)
     |> assign(post_location: post_location)}
  end
end
