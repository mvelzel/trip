defmodule TripWeb.IndexLive do
  use TripWeb, :live_view

  alias Trip.{Locations, Posts}

  @impl true
  def mount(_params, session, socket) do
    locations = Locations.list_locations()
    location = Enum.at(locations, 0)
    post_locations = Posts.list_posts_locations(location.id)

    {:ok,
      socket
      |> assign_defaults(session)
      |> assign(post_locations: post_locations)
      |> assign(location: location)}
  end
end
