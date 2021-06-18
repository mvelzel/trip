defmodule TripWeb.PostsLive.Results.Index do
  use TripWeb, :live_view

  alias Trip.{Posts, Accounts, Locations}

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    posts = Accounts.get_user_posts(socket.assigns.current_user)
    post = Enum.at(posts, 0)

    locations = Locations.list_locations()

    location =
      locations
      |> Enum.at(0)

    post_results =
      if post && location do
        Posts.list_all_post_results(post.id)
        |> Enum.filter(&(&1.group.location_id == location.id))
        |> Enum.sort_by(& &1.inserted_at, {:desc, Date})
      else
        []
      end

    {:ok,
     socket
     |> assign(post_results: post_results)
     |> assign(location: location)
     |> assign(locations: locations)
     |> assign(post: post)
     |> assign(posts: posts)}
  end

  @impl true
  def handle_event("delete-result", %{"index" => index}, socket) do
    post_result =
      socket.assigns.post_results
      |> Enum.at(String.to_integer(index))

    Posts.delete_post_result(post_result)

    post_results =
      if socket.assigns.post && socket.assigns.location do
        Posts.list_all_post_results(socket.assigns.post.id)
        |> Enum.filter(&(&1.group.location_id == socket.assigns.location.id))
        |> Enum.sort_by(& &1.inserted_at, {:desc, Date})
      else
        []
      end

    {:noreply,
     socket
     |> assign(post_results: post_results)}
  end

  def handle_event("post-selected", %{"value" => id}, socket) do
    post = Posts.get_post!(id)

    post_results =
      if post && socket.assigns.location do
        Posts.list_all_post_results(post.id)
        |> Enum.filter(&(&1.group.location_id == socket.assigns.location.id))
        |> Enum.sort_by(& &1.inserted_at, {:desc, Date})
      else
        []
      end

    {:noreply,
     socket
     |> assign(post: post)
     |> assign(post_results: post_results)}
  end

  def handle_event("location-selected", %{"value" => id}, socket) do
    location = Locations.get_location!(id)

    post_results =
      if socket.assigns.post && location do
        Posts.list_all_post_results(socket.assigns.post.id)
        |> Enum.filter(&(&1.group.location_id == location.id))
        |> Enum.sort_by(& &1.inserted_at, {:desc, Date})
      else
        []
      end

    {:noreply,
     socket
     |> assign(post_results: post_results)
     |> assign(location: location)}
  end
end
